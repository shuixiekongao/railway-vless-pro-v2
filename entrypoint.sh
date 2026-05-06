#!/bin/bash

# ==============================
echo " Railway Argo VLESS PRO V2 "
# ==============================

UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}

# 自动获取 DOMAIN
if [ -n "$DOMAIN" ]; then
  export DOMAIN="$DOMAIN"
elif [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  export DOMAIN="$RAILWAY_PUBLIC_DOMAIN"
elif [ -n "$RAILWAY_STATIC_URL" ]; then
  export DOMAIN="$RAILWAY_STATIC_URL"
elif [ -n "$RENDER_EXTERNAL_HOSTNAME" ]; then
  export DOMAIN="$RENDER_EXTERNAL_HOSTNAME"
else
  export DOMAIN="localhost"
fi

ARGO_TOKEN=${ARGO_TOKEN}
PORT=${PORT:-3000}

if [ -z "$ARGO_TOKEN" ]; then
  echo "ARGO_TOKEN missing!"
  exit 1
fi

# 自动替换 UUID 和 DOMAIN
sed "s#__UUID__#$UUID#g; s#__DOMAIN__#$DOMAIN#g" /app/xray-template.json > /app/config.json

/usr/local/xray/xray -config /app/config.json > /app/xray.log 2>&1 &
cloudflared tunnel run --token "$ARGO_TOKEN" > /app/argo.log 2>&1 &
node /app/web.js > /app/web.log 2>&1 &

# internal self ping keepalive
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
echo "DOMAIN : $DOMAIN"
echo ""
echo "VLESS  : vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#Railway-Argo-ProV2"
echo "SUB    : https://${DOMAIN}/sub"
echo "INFO   : https://${DOMAIN}/info"
echo "KEEPALIVE ENABLED"
echo "============================="

tail -f /app/xray.log /app/argo.log /app/web.log
