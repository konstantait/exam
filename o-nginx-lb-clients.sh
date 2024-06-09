#!/usr/bin/env bash

sshpass -p"$HUSH1" ssh root@$NODE1 'apt-get -y install php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-zip php8.1-gd'
sshpass -p"$HUSH1" scp /etc/php/8.1/fpm/pool.d/www.conf \
    root@$NODE1:/etc/php/8.1/fpm/pool.d/www.conf
sshpass -p"$HUSH1" ssh root@$NODE1 'systemctl restart php8.1-fpm'

sshpass -p"$HUSH1" ssh root@$NODE1 'apt-get -y install nginx'
sshpass -p"$HUSH1" scp /etc/nginx/nginx.conf root@$NODE1:/etc/nginx/nginx.conf
sshpass -p"$HUSH1" scp /etc/nginx/conf.d/ssl.conf root@$NODE1:/etc/nginx/conf.d/ssl.conf
sshpass -p"$HUSH1" scp /etc/nginx/sites-available/wordpress.devops.constanta.ua \
    root@$NODE1:/etc/nginx/sites-available/default
sshpass -p"$HUSH1" ssh root@$NODE1 'nginx -t'
sshpass -p"$HUSH1" ssh root@$NODE1 'systemctl restart nginx'


sshpass -p"$HUSH2" ssh root@$NODE2 'apt-get -y install php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-zip php8.1-gd'
sshpass -p"$HUSH2" scp /etc/php/8.1/fpm/pool.d/www.conf \
    root@$NODE2:/etc/php/8.1/fpm/pool.d/www.conf
sshpass -p"$HUSH2" ssh root@$NODE2 'systemctl restart php8.1-fpm'

sshpass -p"$HUSH2" ssh root@$NODE2 'apt-get -y install nginx'
sshpass -p"$HUSH2" scp /etc/nginx/nginx.conf root@$NODE2:/etc/nginx/nginx.conf
sshpass -p"$HUSH2" scp /etc/nginx/conf.d/ssl.conf root@$NODE2:/etc/nginx/conf.d/ssl.conf
sshpass -p"$HUSH2" scp /etc/nginx/sites-available/wordpress.devops.constanta.ua \
    root@$NODE2:/etc/nginx/sites-available/default
sshpass -p"$HUSH2" ssh root@$NODE2 'nginx -t'
sshpass -p"$HUSH2" ssh root@$NODE2 'systemctl restart nginx'

sshpass -p"$HUSH1" ssh root@$NODE1
sshpass -p"$HUSH2" ssh root@$NODE2

nano /etc/systemd/system/multi-user.target.wants/nginx.service
# ExecStartPre=/bin/sleep 5