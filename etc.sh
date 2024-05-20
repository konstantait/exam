#!/usr/bin/env bash

TAB="$(printf '\t')"

IPs=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | tr '\n' ';')
