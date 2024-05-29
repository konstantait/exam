#!/usr/bin/env bash

# debian
cat /etc/debian_version
# 11.9
# 12.5

# ubuntu
cat /etc/lsb-release

uname -a
# debian
# Linux server 5.10.0-28-amd64 #1 SMP Debian 5.10.209-2 (2024-01-31) x86_64 GNU/Linux
# Linux server 6.1.0-21-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.90-1 (2024-05-03) x86_64 GNU/Linux

cat /etc/apt/sources.list | grep "^[^#;]"
# debian
# deb http://deb.debian.org/debian/ bullseye main
# deb-src http://deb.debian.org/debian/ bullseye main
# deb http://security.debian.org/debian-security bullseye-security main
# deb-src http://security.debian.org/debian-security bullseye-security main
# deb http://deb.debian.org/debian/ bullseye-updates main
# deb-src http://deb.debian.org/debian/ bullseye-updates main

sudo cp /etc/apt/sources.list{,.default}

sudo apt-get update && sudo apt-get -y upgrade

# debian 11 -> debian 12
sudo sed -i "s|bullseye|bookworm|g" /etc/apt/sources.list
# ubuntu 20 -> ubuntu 22
sudo sed -i "s|focal|jammy|g" /etc/apt/sources.list

sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove

sudo reboot