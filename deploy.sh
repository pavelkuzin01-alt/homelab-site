#!/usr/bin/env bash
set -euo pipefail

SITE_DIR=/var/www/homelab
CONF=/etc/nginx/sites-available/homelab
CERT=/etc/ssl/certs/pavel.test.crt
KEY=/etc/ssl/private/pavel.test.key

if [[ ! -f "$CERT" ]]; then
    echo "Создаю самоподписанный сертификат..."
    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY" -out "$CERT" \
        -subj "/CN=pavel.test" -addext "subjectAltName=DNS:pavel.test"
fi

sudo mkdir -p "$SITE_DIR"
sudo cp -r site/. "$SITE_DIR/"
sudo cp nginx/homelab.conf "$CONF"
sudo ln -sf "$CONF" /etc/nginx/sites-enabled/homelab

sudo nginx -t && sudo systemctl reload nginx
echo "Готово: сайт выложен"

