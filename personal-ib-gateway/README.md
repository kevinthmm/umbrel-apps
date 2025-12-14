## Personal IB Gateway (Umbrel app)

This app wraps Interactive Brokers IB Gateway with a virtual X display, x11vnc, and noVNC so you can reach the Java login window from your browser.

### Quick start

- Build from this folder: `docker compose build`. Always pulls the latest IB Gateway for `linux-arm`.
- Run on Umbrel: open the app from the Umbrel dashboard; noVNC is proxied through Umbrel’s app proxy. API ports 4001 (live) and 4002 (paper) are mapped through.
- Persisted data lives in `${APP_DATA_DIR}/config` (Jts settings) and `${APP_DATA_DIR}/logs`.

### Raspberry Pi / ARM note

IB Gateway has separate installers per arch. On Raspberry Pi use `IBG_ARCH=linux-arm` (default here). If you build on x86, set `IBG_ARCH=linux-x64` or cross-build multi-arch images.

### Runtime knobs

- `RESOLUTION`: virtual display size, defaults to `1280x800x24`.
- `VNC_PASSWORD`: optional password for x11vnc/noVNC. Leave empty to disable auth (not recommended).

### Security reminders

- Access noVNC only through Umbrel or your LAN/VPN. Do not expose publicly.
- Credentials entered into the IB Gateway login window are handled by the IB app; store them safely and prefer network segmentation over open ports.

### Daily restart

IB Gateway usually requires a fresh login each day. If you want automation, layer your own scheduler to restart the container and log in via the web UI or an external automation stack.
