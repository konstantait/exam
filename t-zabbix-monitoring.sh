#!/usr/bin/env bash

sshpass -p"$HUSH1" ssh root@$NODE1
sshpass -p"$HUSH2" ssh root@$NODE2

# nginx

sudo systemctl disable apache2
nginx -v
nginx -V 2>&1 | grep -o with-http_stub_status_module
# wget http://nginx.org/download/nginx-1.13.12.tar.gz
# tar xfz nginx-1.22.1.tar.gz
# cd nginx-1.22.1/
# ./configure --with-http_stub_status_module
# make
# make install

sudo tee /etc/nginx/conf.d/stub_status.conf >/dev/null <<'EOF'
server {
    listen 127.0.0.1:80;
    server_name 127.0.0.1;
    location = /basic_status {
        stub_status;
        allow 127.0.0.1;
        allow ::1;
        deny all;
    }
}
EOF
nginx -t
systemctl restart nginx
systemctl status nginx
curl http://127.0.0.1/basic_status


# apache

apache2ctl -M | grep status
#status_module (shared)
cat /etc/apache2/mods-enabled/status.conf | grep "^[^#;]"
curl http:/127.0.0.1:81/server-status


# mariadb

mysql -uroot -p$HUSH -e "create user zbx_monitor@'%' identified by '$HUSH';"
mysql -uroot -p$HUSH -e "grant replication client, process, show databases, show view on *.* to zbx_monitor@'%';"
# Macros
# {$MYSQL.DSN} tcp://localhost:3306
# {$MYSQL.USER} zbx_monitor
# {$MYSQL.PASSWORD} $HUSH