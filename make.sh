#!/usr/bin/env bash

pt-get -y install build-essential make automake autoconf

mkdir build && cd build
wget http://ftp.midnight-commander.org/mc-4.8.30.tar.xz
tar xvf mc-4.8.30.tar.xz
cd mc-4.8.30
./configure