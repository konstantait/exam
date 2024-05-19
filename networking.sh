#!/usr/bin/env bash

ip a

cat /etc/network/interfaces

# server
sudo sed -i "s|allow-hotplug enp0s3|auto enp0s3|g" /etc/network/interfaces

sudo tee -a /etc/network/interfaces >/dev/null <<EOF
auto enp0s8
iface enp0s8 inet static
   address 192.168.100.1
   netmask 255.255.255.0
   network 192.168.100.0
   broadcast 192.168.100.255
EOF

sudo ifdown --exclude=lo -a && sudo ifup --exclude=lo -a
# sudo systemctl restart systemd-networkd

cat /etc/sysctl.conf
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

netstat -nltp
