#!/usr/bin/env bash

# node 1 (backup server)

sudo apt-get -y install nfs-kernel-server
sudo cp /etc/exports{,.original}
sudo tee /etc/exports > /dev/null <<EOF
/backups  ${LAN_NETWORK}(rw,sync,no_root_squash,no_subtree_check)
EOF
sudo systemctl restart nfs-kernel-server

# server

sudo apt-get -y install nfs-common
sudo cp /etc/fstab{,.original}
mkdir /backups
chmod -R 700 /backups
sudo mount -t nfs $NODE1:/backups /backups
# sudo umount /backups
sudo tee -a /etc/fstab > /dev/null <<EOF
$NODE1:/backups    /backups     nfs  defaults  0  0
EOF

sudo tee /root/backup.sh > /dev/null <<'EOF'
#!/bin/bash
set -o allexport; source /root/.env; set +o allexport

BACKUP_ROOT="/backups"
BACKUP_PATH="${BACKUP_ROOT}/$(date +%Y-%m-%d)"

FOLDERS=( "/etc" "/home/radmin" "/home/itedu" )
BACKUP_DB_NAME="wordpress-$(date +%Y-%m-%d-%H-%M-%S).sql.gz"

mkdir -p ${BACKUP_PATH}

mysqldump -h 127.0.0.1 -P 3306 -u wproot -p"$HUSH" wordpress | gzip > "${BACKUP_PATH}/${BACKUP_DB_NAME}"

for folder in "${FOLDERS[@]}"; do
    name="$(echo "$folder" | cut -c 2-)"
    name="$(echo "$name" | tr '/' '-')"
    name="${name}-$(date +%Y-%m-%d-%H-%M-%S).tar.gz"
    tar -czf "${BACKUP_PATH}/${name}" --absolute-names $folder  
done

olderThan="$(date --date "-7 days" +%s)"
find "${BACKUP_ROOT}" -type f -exec ls -lah --time-style=long-iso {} \; | while read -r line; do
    createDate="$(echo "$line" | awk '{print $6" "$7}')"
    createDate="$(date -d "$createDate" +%s)"
    if [[ "$createDate" -lt "$olderThan" ]]; then
        fileName="$(echo "$line" | awk '{print $8}')"
        if [[ "$fileName" != "" ]]; then
            rm "$fileName"
        fi
    fi
done

find "${BACKUP_ROOT}" -type d -empty -delete
EOF

sudo chmod +x /root/backup.sh

sudo tee /etc/systemd/system/backup.timer > /dev/null <<'EOF'
[Unit]
Description=Backup to NFS timer
Requires=backup.service

[Timer]
Unit=backup.service
OnCalendar=*-*-* 1:00:00
# OnCalendar=*-*-* *:0/5

[Install]
WantedBy=timers.target
EOF

sudo tee /etc/systemd/system/backup.service > /dev/null <<'EOF'
[Unit]
Description=Backup to NFS service
After=network.target

[Service]
User=root
EnvironmentFile=/root/.env
ExecStart=/bin/bash /root/backup.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable backup.timer
sudo systemctl start backup.timer
sudo systemctl daemon-reload


[Unit]
Description=Gunicorn instance to serve app
After=network.target

[Service]
User=ubuntu
Group=www-data
WorkingDirectory=/home/ubuntu/app
Environment="PATH=/home/ubuntu/app/venv/bin"
EnvironmentFile=/home/ubuntu/.environment
ExecStart=/home/ubuntu/app/venv/bin/gunicorn --workers 1 --bind unix:app.sock -m 007 app:app

[Install]
WantedBy=multi-user.target