#!/usr/bin/env bash

# vsftpd server

apt-get -y install vsftpd

cat /etc/ftpusers
cat /etc/vsftpd.conf | grep "^[^#;]"
cp /etc/vsftpd.conf{,.original}

FTP_PATH=$(cat /etc/passwd | grep -w ftp | cut -d':' -f6)
mkdir -p "${FTP_PATH}/upload"
chown ftp:ftp "${FTP_PATH}/upload"

tee /etc/vsftpd.conf > /dev/null <<EOF
listen=YES
listen_ipv6=NO
anonymous_enable=YES
local_enable=YES
write_enable=YES
local_umask=022
anon_umask=022
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES
anon_world_readable_only=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
vsftpd_log_file=/var/log/vsftpd.log
xferlog_file=/var/log/xfer.log
xferlog_std_format=YES
idle_session_timeout=600
data_connection_timeout=120
nopriv_user=ftp
ascii_upload_enable=YES
ascii_download_enable=YES
ftpd_banner=Welcome to FTP service.
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
allow_writeable_chroot=YES
pasv_address=$WAN_IP
pasv_enable=YES
pasv_min_port=50000
pasv_max_port=50099
EOF

systemctl restart vsftpd
systemctl status vsftpd
sudo netstat -tulpn | grep LISTEN | grep vsftpd

# samba server

sudo apt-get -y install samba

cat /etc/samba/smb.conf | grep "^[^#;]"
sudo cp /etc/samba/smb.conf{,.original}
sudo tee /etc/samba/smb.conf > /dev/null <<EOF
[global]
    interfaces = $LAN
    bind interfaces only = yes
    workgroup = WORKGROUP
    log file = /var/log/samba/log.%m
    max log size = 1000
    logging = file
    panic action = /usr/share/samba/panic-action %d
    server role = standalone server
    obey pam restrictions = yes
    unix password sync = yes
    passwd program = /usr/bin/passwd %u
    passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
    pam password change = yes
    map to guest = bad user
    usershare allow guests = yes
    guest account = ftp
[upload]
    comment = upload
    public = yes
    path = /srv/ftp/upload
    create mask = 640
    writeable = yes
    guest ok = yes
    browseable = yes
    max connections = 10
EOF

testparm -s

sudo smbpasswd -a ftp
sudo chmod -R 0755 /srv/ftp/upload

sudo systemctl restart smbd
sudo systemctl restart nmbd

sudo netstat -tulpn | grep LISTEN | grep smbd

sshpass -p"$HUSH1" ssh root@$NODE1
sudo apt-get -y install cifs-utils
sudo mkdir /upload
sudo mount -t cifs //$SERVER/upload /upload