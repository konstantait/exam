#!/usr/bin/env bash

sudo apt-get -y install nginx
sudo systemctl status nginx
sudo netstat -tulpn | grep LISTEN | grep nginx

cat /etc/nginx/nginx.conf | grep -v "#" | grep -v "^$"
sudo cp /etc/nginx/nginx.conf{,.original}
sudo tee /etc/nginx/nginx.conf > /dev/null <<'EOF'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;
events {
    worker_connections 1024;
    multi_accept on;
}
http {
    sendfile on;
    tcp_nopush on;
    types_hash_max_size 2048;
    server_tokens off;
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

sudo tee /etc/nginx/conf.d/ssl.conf > /dev/null <<'EOF'
    ssl_prefer_server_ciphers on;
EOF

cat /etc/nginx/sites-available/default | grep -v "#" | grep -v "^$"
sudo tee /etc/nginx/sites-available/devops.constanta.ua >/dev/null <<'EOF'
server {
    listen 80;
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

sudo mkdir -p /var/www/devops.constanta.ua
sudo chown -R www-data:www-data /var/www/devops.constanta.ua
sudo -u www-data git clone https://github.com/xriley/DevBook-Theme.git /var/www/devops.constanta.ua

sudo ln -s /etc/nginx/sites-available/devops.constanta.ua /etc/nginx/sites-enabled/devops.constanta.ua
# sudo unlink /etc/nginx/sites-enabled/devops.constanta.ua

sudo unlink /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl reload nginx
