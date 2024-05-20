#!/usr/bin/env bash

# debian
cat /etc/debian_version
# ubuntu
cat /etc/lsb-release
uname -a

cat /etc/apt/sources.list | grep "^[^#;]"
cp /etc/apt/sources.list{,.default}

su -

apt-get update
apt-get -y upgrade

# debian 11 -> debian 12
sed -i "s|bullseye|bookworm|g" /etc/apt/sources.list
# ubuntu 20 -> ubuntu 22
sed -i "s|focal|jammy|g" /etc/apt/sources.list

apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove
reboot