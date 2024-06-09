#!/usr/bin/env bash

# server

cat /etc/network/interfaces | grep "^[^#;]"
sudo cp /etc/network/interfaces{,.original}

sudo tee -a /etc/network/interfaces > /dev/null <<EOF
# The secondary network interface
auto $LAN
iface $LAN inet static
        address $LAN_IP
        netmask $LAN_MASK
        network $LAN_NET
        broadcast $LAN_BROADCAST
EOF

sudo ifup $LAN
# sudo ifdown $LAN && sudo ifup $LAN
sudo netstat -tulpn | grep LISTEN


# clients

# mkdir ~/.ssh && touch ~/.ssh/known_hosts
ssh-keyscan -H $NODE1 >> ~/.ssh/known_hosts
ssh-keyscan -H $NODE2 >> ~/.ssh/known_hosts

sshpass -p"$HUSH1" scp .env root@$NODE1:/root/.env
sshpass -p"$HUSH2" scp .env root@$NODE2:/root/.env

sshpass -p"$HUSH1" ssh root@$NODE1
sshpass -p"$HUSH2" ssh root@$NODE2

sshpass -p"$HUSH1" ssh root@$NODE1 'cp /etc/netplan/00-installer-config.yaml{,.original}'
sshpass -p"$HUSH2" ssh root@$NODE2 'cp /etc/netplan/00-installer-config.yaml{,.original}'

IFACE=$(sshpass -p"$HUSH1" ssh root@$NODE1 "ip -br link show | grep ens | cut -d' ' -f1")

sudo tee node1.yaml > /dev/null <<EOF
network:
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
      - $NODE1_CIDR
      gateway4: $SERVER
      nameservers:
        addresses:
        - $SERVER
  version: 2
EOF

sudo tee node2.yaml > /dev/null <<EOF
network:
  ethernets:
    $IFACE:
      dhcp4: no
      addresses:
      - $NODE2_CIDR
      gateway4: $SERVER
      nameservers:
        addresses:
        - $SERVER
  version: 2
EOF

sshpass -p"$HUSH1" scp node1.yaml root@$NODE1:/etc/netplan/00-installer-config.yaml
sshpass -p"$HUSH1" ssh root@$NODE1 'reboot'
sshpass -p"$HUSH2" scp node2.yaml root@$NODE2:/etc/netplan/00-installer-config.yaml
sshpass -p"$HUSH2" ssh root@$NODE2 'reboot'


# network troubleshooting

systemctl cat networking.service
sudo journalctl -u networking.service --no-pager
sudo rm /etc/network/interfaces.d/setup

