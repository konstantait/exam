#!/usr/bin/env bash

su -
apt-get update && apt-get -y install ssh git mc
systemctl status sshd

wget https://raw.githubusercontent.com/konstantait/exam/main/iptables.sh -O /root/iptables.sh 
chmod +x /root/iptables.sh
/etc/systemd/system