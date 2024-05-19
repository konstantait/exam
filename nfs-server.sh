#!/usr/bin/env bash

apt-get -y install nfs-kernel-server
cat /etc/exports
cp /etc/exports{.default}

mkdir -p /srv/nfs/general
mkdir -p /srv/nfs/home

chown nobody:nogroup /srv/nfs/general
echo '/srv/nfs/general    192.168.100.2(rw,sync,no_subtree_check)' > /etc/exports
echo '/srv/nfs/home    192.168.100.2(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports

systemctl restart nfs-kernel-server
systemctl status nfs-kernel-server
