#!/usr/bin/env bash

sudo apt-get -y install iptables

cat /etc/sysctl.conf
sudo cp /etc/sysctl.conf{,.default}
echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -o enp0s3 -j MASQUERADE

wget https://raw.githubusercontent.com/konstantait/exam/main/rules.sh -O /root/rules.sh
chmod +x /root/rules.sh
cat /root/rules.sh | grep "^[^#;]"

sudo tee /etc/systemd/system/iptables.service > /dev/null <<'EOF'
[Unit]
Description=IPtables configuration
Requires=network.target
After=network.target

[Service]
Type=oneshot
User=root
ExecStart=/root/rules.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable iptables.service
sudo systemctl status iptables.service

sudo iptables -L
sudo iptables -t nat -L