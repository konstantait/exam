#!/usr/bin/env bash

apt-get -y install bind9 dnsutils

cat /etc/resolv.conf
cat /etc/bind/named.conf.options | grep "^[^#;]"
cp /etc/bind/named.conf.options{,.default}

# echo 'nameserver 127.0.0.1' > /etc/resolv.conf

wget https://raw.githubusercontent.com/konstantait/exam/main/named.conf.options -O /etc/bind/named.conf.options

named-checkconf

systemctl restart bind9
systemctl status bind9