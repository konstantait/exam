#!/usr/bin/env bash

apt-get -y install ntp
systemctl status ntp

timedatectl
timedatectl list-timezones | grep Kyiv
timedatectl set-timezone Europe/Kyiv

ntpq -p

timedatectl