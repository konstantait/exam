#!/usr/bin/env bash

sudo apt-get -y install iptables

cat /etc/sysctl.conf | grep "^[^#;]"
sudo cp /etc/sysctl.conf{,.original}
sudo bash -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
sudo sysctl -p

sudo mkdir -p /etc/iptables
sudo tee /etc/iptables/rules > /dev/null <<EOF
#!/usr/bin/env bash
iptables -F
iptables -t nat -F
iptables -t mangle -F
iptables -X
iptables -t nat -X
iptables -t mangle -X
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 2222 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -s $TRUSTED_IP -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 50000:50099 -s $TRUSTED_IP -j ACCEPT
iptables -A INPUT -i $WAN -j REJECT --reject-with icmp-host-prohibited
iptables -t nat -A POSTROUTING -o $WAN -s $LAN_NETWORK -j SNAT --to-source $WAN_IP
EOF

# iptables -t nat -A POSTROUTING -o $WAN -j MASQUERADE

sudo chmod +x /etc/iptables/rules

sudo tee /etc/systemd/system/iptables.service > /dev/null <<'EOF'
[Unit]
Description=Iptables configuration
Requires=network.target
After=network.target

[Service]
Type=oneshot
User=root
ExecStart=/etc/iptables/rules

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable iptables.service
sudo systemctl restart iptables.service

sudo iptables -L -vn
sudo iptables -t nat -L -vn

# IPTABLES=$(which iptables)

# if [[ -z "$IPTABLES" ]]; then
#     apt-get update && apt-get -y install iptables
#     IPTABLES=$(which iptables)
# fi

# # Clear All Rules
# $IPTABLES -F
# $IPTABLES -t nat -F
# $IPTABLES -t mangle -F
# $IPTABLES -X
# $IPTABLES -t nat -X
# $IPTABLES -t mangle -X