#!/usr/bin/env bash

sudo apt-get -y install snapd
sudo snap install core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot certonly --manual --preferred-challenges=dns \
    --email konstanta.it@gmail.com \
    --server https://acme-v02.api.letsencrypt.org/directory \
    --agree-tos \
    -d devops.constanta.ua -d *.devops.constanta.ua

# https://toolbox.googleapps.com/apps/dig/#TXT/_acme-challenge.devops.constanta.ua.

# Successfully received certificate.
# Certificate is saved at: /etc/letsencrypt/live/devops.constanta.ua/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/devops.constanta.ua/privkey.pem
# This certificate expires on 2024-08-22.
# These files will be updated when the certificate renews.
# NEXT STEPS:
# - This certificate will not be renewed automatically. Autorenewal of --manual certificates requires
#   the use of an authentication hook script (--manual-auth-hook) but one was not provided. To renew
#   this certificate, repeat this same certbot command before the certificate's expiry date.


# migrate to new server
sudo tar -chvzf certs.tar.gz \
    /etc/letsencrypt/archive/devops.constanta.ua \
    /etc/letsencrypt/renewal/devops.constanta.ua.conf

# scp certs.tar.gz to new server
cd /
sudo tar -xvf ~/certs.tar.gz
sudo mkdir -p /etc/letsencrypt/live/devops.constanta.ua
sudo ln -s /etc/letsencrypt/archive/devops.constanta.ua/cert2.pem /etc/letsencrypt/live/devops.constanta.ua/cert.pem
sudo ln -s /etc/letsencrypt/archive/devops.constanta.ua/chain2.pem /etc/letsencrypt/live/devops.constanta.ua/chain.pem
sudo ln -s /etc/letsencrypt/archive/devops.constanta.ua/fullchain2.pem /etc/letsencrypt/live/devops.constanta.ua/fullchain.pem
sudo ln -s /etc/letsencrypt/archive/devops.constanta.ua/privkey2.pem /etc/letsencrypt/live/devops.constanta.ua/privkey.pem

sudo letsencrypt renew --dry-run

# /etc/cron.d/certbot
# SHELL=/bin/sh
# PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# 0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q renew

# cleanup old server
sudo rm /etc/letsencrypt/renewal/devops.constanta.ua.conf
sudo rm -rf /etc/letsencrypt/renewal/devops.constanta.ua