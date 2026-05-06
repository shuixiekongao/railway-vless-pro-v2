#!/bin/bash

echo "=============================="
echo " Railway VLESS FLAGSHIP 2026 "
echo "=============================="

UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
ARGO_TOKEN=${ARGO_TOKEN}
ARGO_DOMAIN=${ARGO_DOMAIN}

# 强制必须使用自定义域名
if [ -z "$ARGO_DOMAIN" ]; then
  echo "ARGO_DOMAIN missing!"
  exit 1
fi

if [ -z "$ARGO_TOKEN" ]; then
  echo "ARGO_TOKEN missing!"
  exit 1
fi

export UUID
export DOMAIN=$ARGO_DOMAIN

# 生成 config
sed "s#UUID#$UUID#g" /app/xray-template.json > /app/config.json

# 启动 Xray（核心代理）
/usr/local/xray/xray -config /app/config.json > /app/xray.log 2>&1 &

# Cloudflare Tunnel
cloudflared tunnel --no-autoupdate run --token "$ARGO_TOKEN" > /app/argo.log 2>&1 &

# Web 面板
node /app/web.js > /app/web.log 2>&1 &

# keepalive
(
while true; do
  sleep 240
  curl -s http://127.0.0.1:3000 >/dev/null
done
) &

sleep 8

echo ""
echo "========= NODE INFO ========="
echo "UUID   : $UUID"
echo "DOMAIN : $ARGO_DOMAIN"
echo ""
echo "VLESS  : vless://${UUID}@${ARGO_DOMAIN}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=xhttp&host=${ARGO_DOMAIN}&path=%2Fvless#FLAGSHIP"
echo "SUB    : https://${ARGO_DOMAIN}/sub"
echo "INFO   : https://${ARGO_DOMAIN}/info"
echo "============================="

tail -f /app/xray.log /app/argo.log /app/web.log
