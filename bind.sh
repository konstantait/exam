#!/usr/bin/env bash

apt-get -y install bind9 dnsutils

cat /etc/resolv.conf
cat /etc/bind/named.conf.options
cp /etc/resolv.conf{,.default}
cp /etc/bind/named.conf.options{,.default}

IPs=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | tr '\n' ';')s

TAB="$(printf '\t')"
tee /etc/bind/named.conf.options >/dev/null <<EOF
options {
${TAB}directory "/var/cache/bind";
${TAB}dnssec-validation auto;
${TAB}allow-query { any; };
${TAB}forwarders { 8.8.8.8; };
${TAB}listen-on-v6 { none; };
};
EOF

echo 'nameserver 127.0.0.1' > /etc/resolv.conf

systemctl restart bind9
systemctl status bind9