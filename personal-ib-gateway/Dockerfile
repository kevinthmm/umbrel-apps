FROM debian:bookworm-slim

ENV IBG_ARCH=linux-arm \
    IBG_HOME=/opt/ibgateway \
    DISPLAY=:0 \
    LANG=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fluxbox \
        libglib2.0-0 \
        libnss3 \
        libxext6 \
        libxi6 \
        libxrender1 \
        libxtst6 \
        novnc \
        openjdk-17-jre \
        procps \
        tzdata \
        websockify \
        x11vnc \
        xauth \
        xvfb \
        xfonts-base \
    && rm -rf /var/lib/apt/lists/*

# Install IB Gateway (supports IBG_ARCH linux-arm or linux-x64) via official installer path.
RUN set -eux; \
    mkdir -p "${IBG_HOME}"; \
    IBG_URL="https://download2.interactivebrokers.com/installers/ibgateway/latest-standalone/ibgateway-latest-standalone-${IBG_ARCH}.sh"; \
    echo "Downloading ${IBG_URL}"; \
    curl -fsSL "${IBG_URL}" -o /tmp/ibgateway.sh; \
    chmod +x /tmp/ibgateway.sh; \
    /tmp/ibgateway.sh -q -dir "${IBG_HOME}"; \
    rm -f /tmp/ibgateway.sh

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080 5900 4001 4002
VOLUME ["/config"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
