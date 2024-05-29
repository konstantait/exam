#!/usr/bin/env bash

sudo apt-get -y install bind9 dnsutils

cat /etc/resolv.conf
cat /etc/bind/named.conf.options | grep "^[^#;]"
sudo cp /etc/bind/named.conf.options{,.default}

sudo tee /etc/bind/named.conf.options > /dev/null <<'EOF'
acl clients {
    192.168.100.0/24;
    localhost;
    localnets;
};
options {
    directory "/var/cache/bind";   
    recursion yes;
    allow-query { clients; };
    forwarders { 8.8.8.8; 8.8.4.4; };
    forward only;
    dnssec-validation auto;
    listen-on-v6 { none; };
};
EOF

# echo 'nameserver 127.0.0.1' > /etc/resolv.conf

named-checkconf

sudo systemctl restart bind9
sudo systemctl status bind9