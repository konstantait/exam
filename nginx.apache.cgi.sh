#!/usr/bin/env bash

sudo apt-get -y install apache2 apache2-doc apache2-utils
sudo systemctl stop apache2

cat /etc/apache2/ports.conf | grep "^[^#;]"
cat /etc/apache2/apache2.conf | grep "^[^#;]"
cat /etc/apache2/envvars | grep "^[^#;]"
# APACHE_ULIMIT_MAX_FILES='ulimit -n 65536'

sudo cp /etc/apache2/ports.conf{,.default}
sudo sed -i "s|Listen 80|Listen 127.0.0.1:81|g" /etc/apache2/ports.conf

cat /etc/apache2/mods-enabled/mpm_event.load
cat /etc/apache2/mods-enabled/rewrite.load
cat /etc/apache2/mods-enabled/cache.load
sudo a2dismod --force autoindex
sudo apt-get -y install libapache2-mod-rpaf
cat /etc/apache2/mods-enabled/rpaf.conf
sudo systemctl restart apache2

dpkg -l | grep apache
# apache2              2.4.59-1~deb12u1  amd64  Apache HTTP Server
# apache2-bin          2.4.59-1~deb12u1  amd64  Apache HTTP Server (modules and other binary files)
# apache2-data         2.4.59-1~deb12u1  all    Apache HTTP Server (common files)
# apache2-doc          2.4.59-1~deb12u1  all    Apache HTTP Server (on-site documentation)
# apache2-utils        2.4.59-1~deb12u1  amd64  Apache HTTP Server (utility programs for web servers)
# libapache2-mod-rpaf  0.6-14            amd64  module for Apache2 which takes the last IP from the 'X-Forwarded-For' header
sudo apachectl -V | grep MPM
# Server MPM:     event

sudo curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
sudo dpkg -i /tmp/debsuryorg-archive-keyring.deb
sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] \
    https://packages.sury.org/php/ bookworm main" > \
    /etc/apt/sources.list.d/php.list'
sudo apt-get update
apt-cache search php

# sudo apt-get -y install php7.4 libapache2-mod-php7.4
# cat /etc/php/7.4/apache2/php.ini | grep "^[^#;]"
# sudo cp /etc/php/7.4/apache2/php.ini{,.default}
sudo apt-get -y install php7.4 php7.4-cgi
cat /etc/php/7.4/cgi/php.ini | grep "^[^#;]"
sudo cp /etc/php/7.4/cgi/php.ini{,.default}
# short_open_tag = On
# max_execution_time = 60
# memory_limit = 256M
# post_max_size = 20M
# upload_max_filesize = 20M

php -v
update-alternatives --config php

sudo a2enmod actions
sudo a2enmod cgi
cat /etc/apache2/conf-enabled/serve-cgi-bin.conf
cat /etc/apache2/conf-available/php7.4-cgi.conf
sudo a2enconf php7.4-cgi
sudo systemctl restart apache2
ls -lah /usr/lib/cgi-bin/

sudo tee /etc/apache2/sites-available/devops.constanta.ua.conf > /dev/null <<'EOF'
<VirtualHost 127.0.0.1:81>
        ServerName devops.constanta.ua
        ServerAdmin webmaster@devops.constanta.ua
        DocumentRoot /var/www/devops.constanta.ua

        <Directory "/var/www/devops.constanta.ua/">
            Options -ExecCGI -Indexes +FollowSymLinks -Multiviews -Includes
        </Directory>
        Action application/x-httpd-php /cgi-bin/php7.4
        
        ErrorLog ${APACHE_LOG_DIR}/devops.constanta.ua_error.log
        CustomLog ${APACHE_LOG_DIR}/devops.constanta.ua_access.log combined
</VirtualHost>
EOF
sudo apache2ctl -t
sudo a2ensite devops.constanta.ua
sudo systemctl reload apache2

sudo tee /etc/nginx/sites-available/devops.constanta.ua > /dev/null <<'EOF'
server {
    listen 443 ssl http2;
    server_name devops.constanta.ua;
    root /var/www/devops.constanta.ua;
    index index.html;
    location ~* ^.+\.(svg|jpg|jpeg|gif|png|ico|zip|gz|rar|bz2|xls|html|exe|pdf|txt|wav|bmp|js|swf|css|xml)$ {
        root /var/www/devops.constanta.ua;
    }
    location / {
        proxy_pass http://127.0.0.1:81;
        include proxy_params;
    }
    access_log /var/log/nginx/devops.constanta.ua_access.log;
    error_log /var/log/nginx/devops.constanta.ua_error.log;
}
EOF
sudo nginx -t
sudo systemctl reload nginx

sudo sudo -u www-data tee /var/www/devops.constanta.ua/info.php > /dev/null <<'EOF'
<?php
    phpinfo();
?>
EOF

sudo ss -tulpn | grep LISTEN
sudo tail -f /var/log/apache2/devops.constanta.ua_access.log
sudo tail -f /var/log/apache2/devops.constanta.ua_error.log
sudo tail -f /var/log/nginx/devops.constanta.ua_access.log;
sudo tail -f error_log /var/log/nginx/devops.constanta.ua_error.log



