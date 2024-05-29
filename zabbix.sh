#!/usr/bin/env bash
# https://www.zabbix.com/documentation/current/en/manual/installation/install

wget https://cdn.zabbix.com/zabbix/sources/stable/6.4/zabbix-6.4.15.tar.gz
tar -zxvf zabbix-6.4.15.tar.gz
cd zabbix-6.4.15

sudo addgroup --system --quiet zabbix
sudo adduser --quiet --system --disabled-login --ingroup zabbix --home /var/lib/zabbix --no-create-home zabbix

export CFLAGS="-std=gnu99"

sudo apt-get -y install default-libmysqlclient-dev \
    pkg-config libxml2-dev libsnmp-dev libopenipmi-dev libevent-dev \
    libcurl4-openssl-dev libpcre3-dev # libssh2-1-dev
# sudo apt-get -y install default-jdk libiksemel-dev libldap2-dev

./configure --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi
sudo make install

# https://www.zabbix.com/documentation/current/en/manual/appendix/install/db_scripts

mysql -uroot -p$HUSHHUSH -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
mysql -uroot -p$HUSHHUSH -e "create user zabbix@localhost identified by '$HUSHHUSH'"
mysql -uroot -p$HUSHHUSH -e "grant all privileges on zabbix.* to zabbix@localhost;"
mysql -uroot -p$HUSHHUSH -e "SET GLOBAL log_bin_trust_function_creators = 1;"

cd database/mysql
mysql -uzabbix -p$HUSHHUSH zabbix < schema.sql
mysql -uzabbix -p$HUSHHUSH zabbix < images.sql
mysql -uzabbix -p$HUSHHUSH --default-character-set=utf8mb4 zabbix < data.sql

mysql -uroot -p$HUSHHUSH -e "SET GLOBAL log_bin_trust_function_creators = 0;"

cat /usr/local/etc/zabbix_server.conf | grep -v "#" | grep -v "^$"
cat /usr/local/etc/zabbix_agentd.conf
