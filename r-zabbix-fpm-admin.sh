#!/usr/bin/env bash

sudo mv /etc/php/8.1/fpm/pool.d/www.conf /etc/php/8.1/fpm/pool.d/www.conf.wordpress

sudo tee /etc/php/8.1/fpm/pool.d/www.conf > /dev/null <<'EOF'
[zabbix]
user = zabbix
group = zabbix
listen = /run/php/php8.1-fpm.sock
listen.owner = zabbix
listen.group = www-data
listen.mode = 0660
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
pm.max_requests = 200
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/sessions/
php_value[max_execution_time] = 300
php_value[memory_limit] = 128M
php_value[post_max_size] = 16M
php_value[upload_max_filesize] = 2M
php_value[max_input_time] = 300
php_value[max_input_vars] = 10000
EOF

sudo systemctl restart php8.1-fpm
sudo systemctl status php8.1-fpm

php -m
# https://www.zabbix.com/documentation/current/en/manual/installation/requirements
sudo apt-get -y install php8.1-gd php8.1-bcmath php8.1-xmlreader php8.1-xmlwriter php8.1-mbstring

sudo tee /etc/nginx/sites-available/zabbix.devops.constanta.ua > /dev/null <<'EOF'
upstream zabbix {
    server unix:/run/php/php8.1-fpm.sock;
}
server {
    listen 443 ssl http2;
    server_name zabbix.devops.constanta.ua;
    root /var/www/zabbix.devops.constanta.ua;
    index index.php;
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_intercept_errors on;
        fastcgi_pass zabbix;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/zabbix.devops.constanta.ua /etc/nginx/sites-enabled/zabbix.devops.constanta.ua
sudo nginx -t
sudo systemctl reload nginx

# change default password Admin/zabbix to $HUSH

sudo tee /var/www/zabbix.devops.constanta.ua/info.php > /dev/null <<'EOF'
<?php
    phpinfo();
?>
EOF

