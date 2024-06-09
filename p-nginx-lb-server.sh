#!/usr/bin/env bash

mysql -uroot -p$HUSH -e "rename user wproot@localhost to wproot@'%';"

sudo sed -i "s|.*bind-address.*|bind-address = 0.0.0.0|" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mysql
sudo netstat -tulpn | grep LISTEN | grep mariadb

cd /var/www/wordpress.devops.constanta.ua
sudo -u wproot wp config set DB_HOST $SERVER

sudo unlink /etc/nginx/sites-enabled/wordpress.devops.constanta.ua

sudo tee /etc/nginx/sites-available/lb > /dev/null <<EOF
upstream wordpress {
    # ip_hash;
    server $NODE1:443 weight=2 max_fails=2 fail_timeout=2s;
    server $NODE2:443 weight=2 max_fails=2 fail_timeout=2s;
}
server {
    listen 443 ssl http2;
    server_name wordpress.devops.constanta.ua;
    location / {
        proxy_pass https://wordpress;
        include proxy_params;
    }
    access_log /var/log/nginx/lb_access.log;
    error_log /var/log/nginx/lb_error.log;
}
EOF
sudo ln -s /etc/nginx/sites-available/lb /etc/nginx/sites-enabled/lb
sudo nginx -t
sudo systemctl reload nginx

sudo -u wproot tee /var/www/wordpress.devops.constanta.ua/sessions.php > /dev/null <<'EOF'
<?php
    header('Content-Type: text/plain');
    session_start();
    if(!isset($_SESSION['visit']))
    {
        echo "This is the first time you're visiting this server";
        $_SESSION['visit'] = 0;
    }
    else
        echo "Your number of visits: ".$_SESSION['visit'];
    $_SESSION['visit']++;
    echo "\nServer IP: ".$_SERVER['SERVER_ADDR'];
    echo "\nClient IP: ".$_SERVER['REMOTE_ADDR'];
    echo "\nX-Forwarded-for: ".$_SERVER['HTTP_X_FORWARDED_FOR']."\n";
    print_r($_COOKIE);
?>
EOF



