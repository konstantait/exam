#!/usr/bin/env bash

cat /etc/fstab | grep "^[^#;]"
sudo cp /etc/fstab{,.default}

# simulation project work source disk with free space
# & lvm partition with free extends
# ---------------------------------------------------
df -h
sudo fdisk -l
lsblk
# NAME                  MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda                     8:0    0    8G  0 disk
# ├─sda1                  8:1    0  487M  0 part /boot
# ├─sda2                  8:2    0    1K  0 part
# └─sda5                  8:5    0  7.5G  0 part
#  ├─server--vg-root   254:0    0  6.6G  0 lvm  /
#  └─server--vg-swap_1 254:1    0  980M  0 lvm  [SWAP]
# sdb                     8:16   0    8G  0 disk
sudo fdisk /dev/sdb
# n - add a new partition
# p - primary partition type
# 1 - default partition number
# 2048 - default first sector
# +4G - last sector or size
# t - change a partition type
# 8e - linux lvm
# w - write table to disk and exit
# q - quit without saving changes
lsblk
# sdb                     8:16   0    8G  0 disk
# └─sdb1                  8:17   0    4G  0 part
sudo pvcreate /dev/sdb1


# extend root partition
# ---------------------
sudo pvs
#  PV         VG        Fmt  Attr PSize  PFree
#  /dev/sda5  server-vg lvm2 a--  <7.52g    0
#  /dev/sdb1            lvm2 ---   4.00g 4.00g
sudo vgextend server-vg /dev/sdb1
#  /dev/sda5  server-vg lvm2 a--  <7.52g     0
#  /dev/sdb1  server-vg lvm2 a--  <4.00g <4.00g
sudo vgdisplay
#  --- Volume group ---
#  VG Name               server-vg
#  Free  PE / Size       1023 / <4.00 GiB
#  VG UUID               qOqODY-fqP4-1eaI-PNZ2-jr0Z-hpQd-CZdZmn
sudo vgdisplay -c | rev | cut -d':' -f2 | rev
sudo lvextend -l +$(!!) /dev/server-vg/root
#  /dev/sda5  server-vg lvm2 a--  <7.52g    0
#  /dev/sdb1  server-vg lvm2 a--  <4.00g    0
sudo resize2fs /dev/mapper/server--vg-root
# sda                     8:0    0    8G  0 disk
# ├─sda1                  8:1    0  487M  0 part /boot
# ├─sda2                  8:2    0    1K  0 part
# └─sda5                  8:5    0  7.5G  0 part
#  ├─server--vg-root   254:0    0 10.6G  0 lvm  /
#  └─server--vg-swap_1 254:1    0  980M  0 lvm  [SWAP]
# sdb                     8:16   0    8G  0 disk
# └─sdb1                  8:17   0    4G  0 part
#  └─server--vg-root   254:0    0 10.6G  0 lvm  /
sudo reboot


# extend /var/lib/mysql
# ---------------------
sudo fdisk /dev/sdb
# n - add a new partition
# p - primary partition type
# 2 - default partition number
# 8390656 - default first sector
# 16777215 - default sector or size
# t - change a partition type
# 8e - linux lvm
# w - write table to disk and exit
# q - quit without saving changes
lsblk
# sdb                     8:16   0    8G  0 disk
# ├─sdb1                  8:17   0    4G  0 part
# │ └─server--vg-root   254:0    0 10.6G  0 lvm  /
# └─sdb2                  8:18   0    4G  0 part
sudo pvcreate /dev/sdb2
#  /dev/sda5  server-vg lvm2 a--  <7.52g     0
#  /dev/sdb1  server-vg lvm2 a--  <4.00g     0
#  /dev/sdb2            lvm2 ---  <4.00g <4.00g
sudo vgcreate mysql-vg /dev/sdb2
#  /dev/sda5  server-vg lvm2 a--  <7.52g     0
#  /dev/sdb1  server-vg lvm2 a--  <4.00g     0
#  /dev/sdb2  mysql-vg  lvm2 a--  <4.00g <4.00g
sudo lvcreate -l100%FREE mysql-vg -n data
#  /dev/sda5  server-vg lvm2 a--  <7.52g    0
#  /dev/sdb1  server-vg lvm2 a--  <4.00g    0
#  /dev/sdb2  mysql-vg  lvm2 a--  <4.00g    0
sudo lvs
#  LV     VG        Attr       LSize
#  data   mysql-vg  -wi-a-----  <4.00g
#  root   server-vg -wi-ao---- <10.56g
#  swap_1 server-vg -wi-ao---- 980.00m

# sudo systemctl stop mysql
# sudo systemctl status mysql
# sudo ss -tulpn | grep LISTEN
# sudo mv /var/lib/mysql{,.original}

sudo mkdir /var/lib/mysql
ls /dev/mapper/ | grep mysql
# mysql--vg-data
sudo mkfs -t ext4 /dev/mapper/mysql--vg-data

# sudo mount -t ext4 /dev/mapper/mysql--vg-data /var/lib/mysql
# chown -R mysql:mysql /var/lib/mysql
# sudo rsync -av /var/lib/mysql.original/ /var/lib/mysql
# sudo systemctl start mysql
# sudo systemctl status mysql

echo '/dev/mapper/mysql--vg-data /var/lib/mysql   ext4    errors=remount-ro 0       1' | \
    sudo tee -a /etc/fstab > /dev/null

sudo reboot
