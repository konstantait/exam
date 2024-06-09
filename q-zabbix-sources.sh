#!/usr/bin/env bash

# https://www.zabbix.com/documentation/current/en/manual/installation/install

sudo mkdir -p /var/www/zabbix.devops.constanta.ua
sudo useradd -d /var/www/zabbix.devops.constanta.ua -s /usr/sbin/nologin zabbix
sudo chown zabbix:www-data /var/www/zabbix.devops.constanta.ua

wget https://cdn.zabbix.com/zabbix/sources/stable/6.4/zabbix-6.4.15.tar.gz
tar -zxvf zabbix-6.4.15.tar.gz
cd zabbix-6.4.15

sudo apt-get -y install default-libmysqlclient-dev \
    pkg-config libxml2-dev libsnmp-dev libopenipmi-dev libevent-dev \
    libcurl4-openssl-dev libpcre3-dev libssh2-1-dev
# sudo apt-get -y install default-jdk libiksemel-dev libldap2-dev

sudo apt-get -y install gcc make build-essential
export CFLAGS="-std=gnu99"
./configure --enable-server --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi
# --enable-agent
sudo make install

# https://www.zabbix.com/documentation/current/en/manual/appendix/install/db_scripts

mysql -uroot -p$HUSH -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -uroot -p$HUSH -e "create user zabbix@localhost identified by '$HUSH';"
mysql -uroot -p$HUSH -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -uroot -p$HUSH -e "SET GLOBAL log_bin_trust_function_creators = 1;"

cd database/mysql
mysql -uzabbix -p$HUSH zabbix < schema.sql
mysql -uzabbix -p$HUSH zabbix < images.sql
mysql -uzabbix -p$HUSH --default-character-set=utf8mb4 zabbix < data.sql
mysql -uroot -p$HUSH -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# cd /var/www/zabbix.devops.constanta.ua
# sudo -u zabbix cp -R ~/zabbix-6.4.15/ui/* .

sudo cp -R ./zabbix-6.4.15/ui/* /var/www/zabbix.devops.constanta.ua
sudo chown -R zabbix:zabbix /var/www/zabbix.devops.constanta.ua
sudo chown zabbix:www-data /var/www/zabbix.devops.constanta.ua