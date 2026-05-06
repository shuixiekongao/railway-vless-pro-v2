#!/bin/bash

echo "=============================="
echo " Railway Argo VLESS FLAGSHIP "
echo "=============================="

UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
ARGO_TOKEN=${ARGO_TOKEN}
ARGO_DOMAIN=${ARGO_DOMAIN}
PORT=${PORT:-3000}

if [ -z "$ARGO_TOKEN" ]; then
  echo "ARGO_TOKEN missing!"
  exit 1
fi

if [ -z "$ARGO_DOMAIN" ]; then
  echo "ARGO_DOMAIN missing!"
  exit 1
fi

export UUID
export DOMAIN=$ARGO_DOMAIN

# 自动替换 UUID
sed "s#UUID#$UUID#g" /app/xray-template.json > /app/config.json

# 启动 Xray
/usr/local/xray/xray -config /app/config.json > /app/xray.log 2>&1 &

# 启动 Cloudflare Tunnel
cloudflared tunnel --no-autoupdate run --token "$ARGO_TOKEN" > /app/argo.log 2>&1 &

# 启动 Web 面板（仅展示）
node /app/web.js > /app/web.log 2>&1 &

# keepalive 防休眠（打web面板）
(
while true
do
  sleep 240
  curl -I http://127.0.0.1:$PORT >/dev/null 2>&1
done
) &

sleep 10

echo ""
echo "========= NODE INFO ========="
echo "UUID   : $UUID"
echo "DOMAIN : $ARGO_DOMAIN"
echo ""
echo "VLESS  : vless://${UUID}@${ARGO_DOMAIN}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=xhttp&host=${ARGO_DOMAIN}&path=%2Fvless#Railway-Argo-Flagship"
echo "SUB    : https://${ARGO_DOMAIN}/sub"
echo "INFO   : https://${ARGO_DOMAIN}/info"
echo "KEEPALIVE ENABLED"
echo "============================="

tail -f /app/xray.log /app/argo.log /app/web.log
