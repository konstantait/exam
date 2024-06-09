#!/usr/bin/env bash

sudo apt-get -y install bind9 dnsutils
sudo systemctl status bind9
sudo netstat -tulpn | grep LISTEN | grep named

cat /etc/bind/named.conf.options | grep "^[^#;]"
sudo cp /etc/bind/named.conf.options{,.original}
sudo tee /etc/bind/named.conf.options > /dev/null <<EOF
acl clients {
    $LAN_NETWORK;
    localhost;
};
options {
    listen-on port 53 { clients; };
    directory "/var/cache/bind";   
    recursion yes;
    allow-query { clients; };
    forwarders { 8.8.8.8; 1.1.1.1; };
    forward only;
    dnssec-validation auto;
    listen-on-v6 { none; };
};
EOF

cat /etc/resolv.conf | grep "^[^#;]"
sudo cp /etc/resolv.conf{,.original}
echo 'nameserver 127.0.0.1' > /etc/resolv.conf

named-checkconf

sudo systemctl restart bind9
