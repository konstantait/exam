#!/usr/bin/env bash

sudo cat /etc/fstab
sudo cp /etc/fstab{.default}

sudo apt-get -y install nfs-common
sudo mkdir -p /nfs/general
sudo mkdir -p /nfs/home
sudo mount -t nfs 192.168.100.1:/srv/nfs/general /nfs/general
sudo mount -t nfs 192.168.100.1:/srv/nfs/home /nfs/home
# sudo umount /nfs/home
# sudo umount /nfs/general
echo '192.168.100.1:/srv/nfs/general   /nfs/general  nfs defaults  0       0' >> /etc/fstab
echo '192.168.100.1:/srv/nfs/home      /nfs/home     nfs defaults  0       0' >> /etc/fstab