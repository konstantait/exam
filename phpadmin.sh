#!/usr/bin/env bash
# https://wiki.crowncloud.net/?How_to_Install_PhpMyAdmin_in_Debian_12

HUSHHUSH_BLOWFISH=$(base64 < /dev/urandom | tr -d 'O0Il1+/' | head -c 32)
echo $HUSHHUSH_BLOWFISH
echo "export HUSHHUSH_BLOWFISH=$HUSHHUSH_BLOWFISH" >> ~/.bashrc

sudo mkdir -p /var/lib/phpmyadmin/tmp
sudo chown -R www-data:www-data /var/lib/phpmyadmin

sudo apt-get -y php7.4-mysql php7.4-mbstring
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip phpMyAdmin-5.2.1-all-languages.zip

sudo mkdir /usr/share/phpamydmin
sudo mv phpMyAdmin-5.2.1-all-languages /usr/share/phpmyadmin   

sudo cp /usr/share/phpmyadmin/config.sample.inc.php /usr/share/phpmyadmin/config.inc.php
sudo nano /usr/share/phpmyadmin/config.inc.php
# $cfg['blowfish_secret'] = '<HUSHHUSH_BLOWFISH>';
# $cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';

sudo apt-get -y install php7.4-mysqli php7.4-mbstring php7.4-zip php7.4-gd

sudo tee /etc/apache2/conf-available/phpmyadmin.conf > /dev/null <<'EOF'
Alias /phpmyadmin /usr/share/phpmyadmin
<Directory /usr/share/phpmyadmin>
    Options FollowSymLinks
    DirectoryIndex index.php
    <IfModule mod_php7.4.c>
        <IfModule mod_mime.c>
            AddType application/x-httpd-php .php
        </IfModule>
        <FilesMatch ".+\.php$">
            SetHandler application/x-httpd-php
        </FilesMatch>
        php_flag magic_quotes_gpc Off
        php_flag track_vars On
        php_flag register_globals Off
        php_admin_flag allow_url_fopen Off
        php_value include_path .
        php_admin_value upload_tmp_dir /var/lib/phpmyadmin/tmp
        php_admin_value open_basedir /usr/share/phpmyadmin/:/etc/phpmyadmin/:/var/lib/phpmyadmin/:/usr/share/php/php-gettext/:/usr/share/javascript/:/usr/share/php/tcpdf/
        php_admin_value mbstring.func_overload 0
    </IfModule>
</Directory>
<Directory /usr/share/phpmyadmin/setup>
    <IfModule mod_authz_core.c>
        <IfModule mod_authn_file.c>
            AuthType Basic
            AuthName "phpMyAdmin Setup"
            AuthUserFile /etc/phpmyadmin/htpasswd.setup
        </IfModule>
        Require valid-user
    </IfModule>
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/lib>
    Require all denied
</Directory>
EOF

sudo tee /usr/share/phpmyadmin/info.php > /dev/null <<'EOF'
<?php
    phpinfo();
?>
EOF

sudo apache2ctl -t
sudo a2enconf phpmyadmin.conf
sudo systemctl restart apache2

sudo tee /etc/nginx/phpmyadmin  > /dev/null <<'EOF'
    location /phpmyadmin {
        # allow 10.102.0.186;
        # deny all;
        root /usr/share/;
        location ~* ^.+\.(svg|jpg|jpeg|gif|png|ico|zip|gz|rar|bz2|xls|html|exe|pdf|txt|wav|bmp|js|swf|css|xml)$ {
            root /usr/share/;
        }
        proxy_pass http://127.0.0.1:81;
        include proxy_params;
    }
EOF

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
    include phpmyadmin;
    access_log /var/log/nginx/devops.constanta.ua_access.log;
    error_log /var/log/nginx/devops.constanta.ua_error.log;
}
EOF
sudo nginx -t
sudo systemctl reload nginx

# https://devops.constanta.ua/info.php
# https://devops.constanta.ua/phpmyadmin
# https://devops.constanta.ua/phpmyadmin/info.php
# phpmyadmin database: phpmyadmin
# mysql user: root
# mysql password: $HUSHHUSH