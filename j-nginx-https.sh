#!/usr/bin/env bash

# https://www.sslshopper.com/ssl-checker.html#hostname=devops.constanta.ua

apt-cache show nginx | grep "Version"
# Version: 1.22.1-9
apt-cache show openssl | grep "Version"
# 3.0.11-1~deb12u2

# https://ssl-config.mozilla.org/#server=nginx&version=1.22.1-9&config=intermediate&openssl=3.0.11-1&guideline=5.7

sudo tee /etc/nginx/conf.d/redirect.conf <<'EOF'
server {
    listen 80;
    location / {
        return 301 https://$host$request_uri;
    }
}
EOF

sudo tee /etc/nginx/conf.d/ssl.conf >/dev/null <<'EOF'
    ssl_certificate /etc/letsencrypt/live/devops.constanta.ua/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/devops.constanta.ua/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
    ssl_prefer_server_ciphers off;
    add_header Strict-Transport-Security "max-age=63072000" always;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/devops.constanta.ua/chain.pem;
    resolver 127.0.0.1;
EOF

sudo tee /etc/nginx/sites-available/devops.constanta.ua >/dev/null <<'EOF'
server {
    listen 443 ssl http2;
    server_name devops.constanta.ua;
    root /var/www/devops.constanta.ua;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
    access_log /var/log/nginx/devops.constanta.ua_access.log;
    error_log /var/log/nginx/devops.constanta.ua_error.log;
}
EOF

sudo nginx -t
sudo systemctl reload nginx

