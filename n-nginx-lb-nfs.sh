#!/usr/bin/env bash

# nfs server

sudo apt-get -y install nfs-kernel-server

cat /etc/exports
sudo cp /etc/exports{,.original}
sudo tee /etc/exports > /dev/null <<EOF
/var/www/wordpress.devops.constanta.ua  ${LAN_NETWORK}(rw,sync,no_root_squash,no_subtree_check)
/etc/letsencrypt                        ${LAN_NETWORK}(rw,sync,no_root_squash,no_subtree_check)
EOF

sudo systemctl restart nfs-kernel-server
sudo systemctl status nfs-kernel-server
sudo netstat -tulpn | grep LISTEN | grep rpc


# nfs clients

sshpass -p"$HUSH1" ssh root@$NODE1
sshpass -p"$HUSH2" ssh root@$NODE2

sudo mkdir -p /var/www/wordpress.devops.constanta.ua
sudo mkdir -p /etc/letsencrypt

sudo useradd -d /var/www/wordpress.devops.constanta.ua -s /usr/sbin/nologin wproot
sudo chown -R wproot:www-data /var/www/wordpress.devops.constanta.ua

sudo apt-get -y install nfs-common

sudo cat /etc/fstab | grep "^[^#;]"
sudo cp /etc/fstab{,.original}

sudo mount -t nfs $SERVER:/var/www/wordpress.devops.constanta.ua /var/www/wordpress.devops.constanta.ua
sudo mount -t nfs $SERVER:/etc/letsencrypt /etc/letsencrypt
# sudo umount /var/www/wordpress.devops.constanta.ua
# sudo umount /etc/letsencrypt
sudo tee -a /etc/fstab > /dev/null <<EOF
$SERVER:/var/www/wordpress.devops.constanta.ua     /var/www/wordpress.devops.constanta.ua     nfs  defaults  0  0
$SERVER:/etc/letsencrypt                           /etc/letsencrypt                           nfs  defaults  0  0
EOF
