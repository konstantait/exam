#!/usr/bin/env bash

# debian
cat /etc/debian_version
# 11.8
# 12.5

# ubuntu
cat /etc/lsb-release
# 20.04
# 22.04

uname -a
# debian
# Linux server 5.10.0-27-amd64 #1 SMP Debian 5.10.205-2 (2023-12-31) x86_64 GNU/Linux
# Linux server 6.1.0-21-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.90-1 (2024-05-03) x86_64 GNU/Linux
# ubuntu
# Linux node1 5.4.0-169-generic #187-Ubuntu SMP Thu Nov 23 14:52:28 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
# Linux node1 5.15.0-107-generic #117-Ubuntu SMP Fri Apr 26 12:26:49 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux

cat /etc/apt/sources.list | grep "^[^#;]"
sudo cp /etc/apt/sources.list{,.original}

sudo apt-get update && sudo apt-get -y upgrade

# debian 11 -> debian 12
sudo sed -i "s|bullseye|bookworm|g" /etc/apt/sources.list
# ubuntu 20 -> ubuntu 22
sudo sed -i "s|focal|jammy|g" /etc/apt/sources.list

sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade && sudo apt-get -y autoremove

sudo reboot