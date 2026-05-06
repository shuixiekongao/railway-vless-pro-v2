#!/usr/bin/env bash

sed -i "s/UUID/${UUID}/g" /app/config.json

xray -config /app/config.json >/app/xray.log 2>&1 &

cloudflared tunnel --no-autoupdate run --token ${ARGO_TOKEN} >/app/argo.log 2>&1 &

sleep 8

echo "========= RAILWAY ARGO VLESS FLAGSHIP ========="
echo "UUID   : ${UUID}"
echo "DOMAIN : ${ARGO_DOMAIN}"
echo "VLESS  : vless://${UUID}@${ARGO_DOMAIN}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=xhttp&host=${ARGO_DOMAIN}&path=%2Fvless#Railway-Argo-Flagship"
echo "SUB    : https://${ARGO_DOMAIN}/sub"
echo "INFO   : https://${ARGO_DOMAIN}/info"
echo "==============================================="

python3 -m http.server 7860
