su -

apt-get -y install ssh
systemctl status sshd
ss -tulpn | grep LISTEN

id -Gn radmin
# debian
usermod -aG sudo radmin
# alma
usermod -aG wheel radmin  
exit
exit

# sudo visudo
# sudo cat /etc/sudoers


