#!/usr/bin/env bash

apt-get -y install bind9 dnsutils

cat /etc/resolv.conf
cat /etc/bind/named.conf.options

IPs=$(cat /etc/resolv.conf | grep nameserver | tr -d 'nameserver ' | tr '\n' ';')
TAB="$(printf '\t')"

tee /etc/bind/named.conf.options >/dev/null <<EOF
options {
${TAB}directory "/var/cache/bind";
${TAB}dnssec-validation auto;
${TAB}allow-query { any; };
${TAB}forwarders { $IPs };
${TAB}listen-on-v6 { none; };
};
EOF

echo 'nameserver 127.0.0.1' > /etc/resolv.conf

systemctl restart bind9
systemctl status bind9