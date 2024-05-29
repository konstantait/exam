#!/usr/bin/env bash

sudo mkdir -p /var/www/wordpress.devops.constanta.ua
sudo useradd -d /var/www/wordpress.devops.constanta.ua -s /usr/sbin/nologin wproot
sudo chown -R wproot:www-data /var/www/wordpress.devops.constanta.ua

sudo apt-get -y install php8.2 php8.2-fpm php8.2-mysql
sudo ls -lah /run/php/
# -rw-r--r--  1 root     root       4 May 27 19:20 php8.2-fpm.pid
# srw-rw----  1 www-data www-data   0 May 27 19:20 php8.2-fpm.sock
# lrwxrwxrwx  1 root     root      30 May 27 19:20 php-fpm.sock -> /etc/alternatives/php-fpm.sock

cat /etc/php/8.2/fpm/pool.d/www.conf | grep "^[^#;]"
# [www]
# user = www-data
# group = www-data
# listen = /run/php/php8.2-fpm.sock
# listen.owner = www-data
# listen.group = www-data
# pm = dynamic
# pm.max_children = 5
# pm.start_servers = 2
# pm.min_spare_servers = 1
# pm.max_spare_servers = 3
top -p $(pgrep -d "," php)

sudo cp /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/wordpress.conf
sudo tee /etc/php/8.2/fpm/pool.d/wordpress.conf > /dev/null <<'EOF'
[wordpress]
user = wproot
group = wproot
listen = /run/php/php8.2-fpm.wordpress.sock
listen.owner = wproot
listen.group = www-data
listen.mode = 0660
pm = static
pm.max_children = 50
pm.start_servers = 7
pm.min_spare_servers = 6
pm.max_spare_servers = 8
;pm.max_requests = 500
EOF
sudo mv /etc/php/8.2/fpm/pool.d/www.conf{,.default}
sudo systemctl restart php8.2-fpm
sudo systemctl status php8.2-fpm
sudo ls -lah /run/php/
# -rw-r--r--  1 root     root       5 May 28 23:00 php8.2-fpm.pid
# srw-rw----  1 wproot   www-data   0 May 28 23:00 php8.2-fpm.wordpress.sock
# lrwxrwxrwx  1 root     root      30 May 28 20:08 php-fpm.sock -> /etc/alternatives/php-fpm.sock

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

mysql -uroot -p$HUSHHUSH -e "create database wordpress character set utf8mb4 collate utf8mb4_general_ci;"
mysql -uroot -p$HUSHHUSH -e "create user wproot@localhost identified by '$HUSHHUSH'"
mysql -uroot -p$HUSHHUSH -e "grant all privileges on wordpress.* to wproot@localhost;"
mysql -uroot -p$HUSHHUSH -e "flush privileges;"

cd /var/www/wordpress.devops.constanta.ua
sudo -u wproot wp core download
sudo -u wproot wp core config --dbname=wordpress --dbuser=wproot --dbpass=$HUSHHUSH --dbhost=localhost --dbprefix=wp_
sudo -u wproot wp core install --url='https://wordpress.devops.constanta.ua' \
    --title='Devops Blog' --admin_user=wpadmin --admin_password=$HUSHHUSH --admin_email='konstanta.it@gmail.com'


sudo tee /etc/nginx/sites-available/wordpress.devops.constanta.ua > /dev/null <<'EOF'
upstream wordpress {
    server unix:/run/php/php8.2-fpm.wordpress.sock;
}
server {
    listen 443 ssl http2;
    server_name wordpress.devops.constanta.ua;
    root /var/www/wordpress.devops.constanta.ua;
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
        fastcgi_pass wordpress;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires max;
        log_not_found off;
    }
}
EOF

sudo ln -s /etc/nginx/sites-available/wordpress.devops.constanta.ua /etc/nginx/sites-enabled/wordprress.devops.constanta.ua
sudo nginx -t
sudo systemctl reload nginx

sudo -u wproot tee /var/www/wordpress.devops.constanta.ua/info.php > /dev/null <<'EOF'
<?php
    phpinfo();
?>
EOF

# mysql database: wordpress
# mysql user: wproot
# mysql password: $HUSHHUSH
# https://wordpress.devops.constanta.ua/wp-login.php
# user: wpadmin
# password: $HUSHHUSH
# https://wordpress.devops.constanta.ua/info.php


