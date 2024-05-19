#!/usr/bin/env bash

ip a

cat /etc/network/interfaces
cp /etc/network/interfaces /etc/network/interfaces.default

# server
sudo sed -i "s|allow-hotplug enp0s3|auto enp0s3|g" /etc/network/interfaces

sudo tee -a /etc/network/interfaces >/dev/null <<EOF

# The secondary network interface
auto enp0s8
iface enp0s8 inet static
   address 192.168.100.1
   netmask 255.255.255.0
   network 192.168.100.0
   broadcast 192.168.100.255
EOF

# nodes set 

ifdown enp0s8 && ifup enp0s8
#ifdown --exclude=lo -a && ifup --exclude=lo -a

