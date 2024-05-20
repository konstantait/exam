#!/usr/bin/env bash

cat /etc/debian_version
uname -a

cat /etc/apt/sources.list | grep "^[^#;]"
cp /etc/apt/sources.list{,.default}

su -

apt-get update
apt-get -y upgrade

# debian 11 -> debian 12
sed -i "s|bullseye|bookworm|g" /etc/apt/sources.list

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
reboot