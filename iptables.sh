#!/usr/bin/env bash

apt-get -y install iptables

cat /etc/sysctl.conf
cp /etc/sysctl.conf{,.default}

# echo 1 > /proc/sys/net/ipv4/ip_forward
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

wget https://raw.githubusercontent.com/konstantait/exam/main/iptables.service.sh -O /root/iptables.service.sh
wget https://raw.githubusercontent.com/konstantait/exam/main/iptables.service -O /etc/systemd/system/iptables.service

chmod +x /root/iptables.service.sh
systemctl enable iptables.service
systemctl status iptables.service

iptables -L
iptables -t nat -L