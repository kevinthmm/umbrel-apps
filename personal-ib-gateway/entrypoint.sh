#!/usr/bin/env bash
set -euo pipefail

export DISPLAY=${DISPLAY:-:0}
RESOLUTION=${RESOLUTION:-1280x800x24}
VNC_PORT=${VNC_PORT:-5900}
NOVNC_PORT=${NOVNC_PORT:-8080}
IBG_HOME=${IBG_HOME:-/opt/ibgateway}
CONFIG_ROOT=${CONFIG_ROOT:-/config}
LOG_DIR=${LOG_DIR:-/var/log/ibgateway}

mkdir -p "${CONFIG_ROOT}/Jts" "${LOG_DIR}"

# Keep IB Gateway looking for its defaults in /root/Jts but persist to /config.
if [ ! -e /root/Jts ]; then
  ln -s "${CONFIG_ROOT}/Jts" /root/Jts
fi

echo "Starting virtual display ${DISPLAY} at ${RESOLUTION}"
Xvfb "${DISPLAY}" -screen 0 "${RESOLUTION}" -nolisten tcp &
XVFB_PID=$!

# Lightweight window manager prevents some Java UI sizing issues.
fluxbox -display "${DISPLAY}" >/dev/null 2>&1 &
FLUX_PID=$!

VNC_AUTH_ARGS="-nopw"
if [[ -n "${VNC_PASSWORD:-}" ]]; then
  /usr/bin/x11vnc -storepasswd "${VNC_PASSWORD}" "${CONFIG_ROOT}/.vncpass"
  VNC_AUTH_ARGS="-rfbauth ${CONFIG_ROOT}/.vncpass"
fi

echo "Starting x11vnc on port ${VNC_PORT}"
x11vnc -display "${DISPLAY}" -forever -shared -rfbport "${VNC_PORT}" -localhost -noxdamage ${VNC_AUTH_ARGS} >/dev/null 2>&1 &
VNC_PID=$!

echo "Starting noVNC on port ${NOVNC_PORT}"
/usr/share/novnc/utils/novnc_proxy --vnc "localhost:${VNC_PORT}" --listen "${NOVNC_PORT}" >/dev/null 2>&1 &
NOVNC_PID=$!

# Find IB Gateway launcher produced by the installer.
IBG_BIN=${IBG_BIN:-}
if [[ -z "${IBG_BIN}" ]]; then
  IBG_BIN=$(find "${IBG_HOME}" -maxdepth 4 -type f -name "ibgateway" | head -n 1 || true)
fi

if [[ -z "${IBG_BIN}" ]]; then
  echo "IB Gateway binary not found in ${IBG_HOME}. Check installer URL/version."
  exit 1
fi

echo "Launching IB Gateway via ${IBG_BIN}"
"${IBG_BIN}" &
IBG_PID=$!

cleanup() {
  echo "Shutting down..."
  kill -TERM "${IBG_PID}" "${NOVNC_PID}" "${VNC_PID}" "${FLUX_PID}" "${XVFB_PID}" 2>/dev/null || true
}
trap cleanup TERM INT

wait -n "${IBG_PID}" "${NOVNC_PID}" "${VNC_PID}" "${FLUX_PID}" "${XVFB_PID}"
