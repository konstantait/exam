#!/usr/bin/env bash

ss -tulpn | grep LISTEN | grep sshd
sudo apt-get -y install sshpass, expect

cat /etc/ssh/sshd_config | grep "^[^#;]"
cp /etc/ssh/sshd_config{,.original}
cp /root/.ssh/authorized_keys{,.original}
# add public key from puttygen
nano ./.ssh/authorized_keys

# server (debian11)
# ip: 141.98.109.153
# login: root
# password: $HUSH
# ssh port: 22

# node1 (ubuntu 20.04)
# ip: 172.27.225.124/29
# login: root
# password: $HUSH1
# ssh port: 22

# node2 (ubuntu 22.04)
# ip: 172.27.225.125/29
# login: root
# password: $HUSH2
# ssh port: 22

# network:   172.27.225.120/29
# broadcast: 172.27.225.127
# min:   172.27.225.121
# max:   172.27.225.126

HUSH=
HUSH1=
HUSH2=
HUSHHUSH=$(base64 < /dev/urandom | tr -dC '[:graph:]' | tr -d 'O0Il1+/' | head -c 32)
HUSHHUSHHUSH=$(base64 < /dev/urandom | tr -dC '[:graph:]' | tr -d 'O0Il1+/' | head -c 96)

sudo tee ~/.env >/dev/null <<EOF
HUSH=$HUSH
HUSH1=$HUSH1
HUSH2=$HUSH2
HUSHHUSH=$HUSHHUSH
HUSHHUSHHUSHH=$HUSHHUSHHUSH
WAN=ens192
LAN=ens224
WAN_IP=141.98.109.153
LAN_IP=172.27.225.121
LAN_NET=172.27.225.120
LAN_NETWORK=172.27.225.120/29
LAN_MASK=255.255.255.248
LAN_BROADCAST=172.27.225.127
SERVER=$LAN_IP
NODE1=172.27.225.124
NODE2=172.27.225.125
NODE1_CIDR=172.27.225.124/29
NODE2_CIDR=172.27.225.125/29
URL=devops.constanta.ua
TRUSTED_IP=
EOF

cat ~/.bashrc | grep "^[^#;]"
sudo cp ~/.bashrc{,.original}
sudo tee -a ~/.bashrc >/dev/null <<'EOF'
export $(grep -v '^#' .env | xargs -d '\n')
EOF

useradd -m -s /bin/bash radmin
sudo expect <<EOF
set timeout 1
spawn passwd radmin
expect "New password:"
send "$HUSH\n"
expect "Retype new password:"
send "$HUSH\n"
expect eof
EOF

# sudo visudo
# sudo cat /etc/sudoers

usermod -aG sudo radmin
id -Gn radmin
mkdir -p /home/radmin/.ssh/authorized_key
cp /root/.ssh/authorized_keys /home/radmin/.ssh/authorized_keys
chown radmin:radmin /home/radmin/.ssh/authorized_keys
cp /root/.profile /home/radmin/.profile
cp /root/.bashrc /home/radmin/.bashrc
cp /root/.env /home/radmin/.env
chown radmin:radmin .env

nano /etc/ssh/sshd_config
# PasswordAuthentication no
# Port 2222
sudo systemctl restart sshd


cat /etc/resolv.conf
# search netforce.hosting
# nameserver 1.1.1.1
# nameserver 8.8.8.8

cat /etc/network/interfaces | grep "^[^#;]"
# source /etc/network/interfaces.d/*
# auto lo
# iface lo inet loopback
# auto ens192
# iface ens192 inet static
#        address 141.98.109.153/25
#        gateway 141.98.109.129
#        # dns-* options are implemented by the resolvconf package, if installed
#        dns-nameservers 1.1.1.1 8.8.8.8
#        dns-search netforce.hosting

ip -br link show
# lo      UNKNOWN 00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
# ens192  UP      00:50:56:bf:a6:ca <BROADCAST,MULTICAST,UP,LOWER_UP>
# ens224  DOWN    00:50:56:bf:66:07 <BROADCAST,MULTICAST>

sudo netstat -tulpn | grep LISTEN
# tcp   0  0 0.0.0.0:22  0.0.0.0:*  LISTEN  617/sshd: /usr/sbin
# tcp6  0  0 :::22       :::*       LISTEN  617/sshd: /usr/sbin

history -c && history -w
