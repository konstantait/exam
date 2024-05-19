#!/usr/bin/env bash

apt-get -y install vsftpd

cat /etc/ftpusers
cat /etc/vsftpd.conf | grep "^[^#;]"
cp /etc/vsftpd.conf{.default}

FTP_PATH=$(cat /etc/passwd | grep -w ftp | cut -d':' -f6)
mkdir -p "${FTP_PATH}/upload"
chown ftp:ftp "${FTP_PATH}/upload"

tee /etc/vsftpd.conf >/dev/null <<EOF
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
EOF

systemctl restart vsftpd
systemctl status vsftpd