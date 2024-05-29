#!/usr/bin/env bash

cat /etc/network/interfaces
cp /etc/network/interfaces{,.default}

ip a

# sudo sed -i "s|allow-hotplug eth0|auto eth0|g" /etc/network/interfaces

sudo tee -a /etc/network/interfaces >/dev/null <<EOF

# The secondary network interface
auto eth1
iface eth1 inet static
   address 192.168.100.1
   netmask 255.255.255.0
   network 192.168.100.0
   broadcast 192.168.100.255
EOF

ifdown eth1 && ifup eth1
#ifdown --exclude=lo -a && ifup --exclude=lo -a

# network troubleshooting
systemctl cat networking.service
journalctl -u networking.service --no-pager
rm /etc/network/interfaces.d/setup
