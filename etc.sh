#!/usr/bin/env bash

TAB="$(printf '\t')"
IPs=$(cat /etc/resolv.conf | grep nameserver | cut -d' ' -f2 | tr '\n' ';')
cat /etc/apache2/ports.conf | grep "^[^#;]"
cat /etc/apache2/sites-available/000-default.conf | grep -v '^[[:blank:]]*#[^!]' | grep -v "^$"
cat /etc/apache2/envvars | grep -v "^ *\(--\|#\)" | grep -v "^$"
proxy_set_header X-Forwarded-Proto https;