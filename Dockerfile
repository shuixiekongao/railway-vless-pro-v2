FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl wget unzip ca-certificates procps nodejs npm \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/xray \
    && chmod +x /usr/local/xray/xray \
    && rm -f /tmp/xray.zip

RUN wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

WORKDIR /app
COPY . /app
RUN chmod +x /app/entrypoint.sh
RUN npm install

CMD ["/app/entrypoint.sh"]
