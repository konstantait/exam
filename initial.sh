#!/usr/bin/env bash

su -
apt-get update && apt-get -y install ssh git mc
systemctl status sshd