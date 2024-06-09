#!/usr/bin/env bash

sudo df -h
# Filesystem           Size  Used Avail Use% Mounted on
# /dev/mapper/vg-root  7.3G  1.8G  5.1G  27% /
sudo lsblk
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda           8:0    0   15G  0 disk
# ├─sda1        8:1    0  487M  0 part /boot
# ├─sda2        8:2    0  954M  0 part [SWAP]
# └─sda3        8:3    0 11.2G  0 part
#   └─vg-root 254:0    0  7.4G  0 lvm  /
sudo pvs
# PV         VG Fmt  Attr PSize  PFree
# /dev/sda3  vg lvm2 a--  11.17g 3.72g
sudo vgdisplay
# --- Volume group ---
# Free  PE / Size       953 / 3.72 GiB
# VG UUID               FdbLV0-teig-GtEC-ONPM-Sgc9-etVZ-x5h7Cv


# extend root partition

sudo vgdisplay -c | rev | cut -d':' -f2 | rev
sudo lvextend -l +$(!!) /dev/vg/root
# PV         VG Fmt  Attr PSize  PFree
# /dev/sda3  vg lvm2 a--  11.17g    0
sudo resize2fs /dev/mapper/vg-root
# Filesystem           Size  Used Avail Use% Mounted on
# /dev/mapper/vg-root   11G  1.8G  8.6G  18% /


# create partion & volume group for mysql

sudo fdisk /dev/sda
# n - add a new partition
# p - primary partition type
# 26390528 - default first sector
# 31457279 - default sector or size
# t - change a partition type
# 4 - default partition number
# 8e - linux lvm
# w - write table to disk and exit
# NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
# sda           8:0    0   15G  0 disk
# ├─sda1        8:1    0  487M  0 part /boot
# ├─sda2        8:2    0  954M  0 part [SWAP]
# ├─sda3        8:3    0 11.2G  0 part
# │ └─vg-root 254:0    0 11.2G  0 lvm  /
# └─sda4        8:4    0  2.4G  0 part
sudo pvcreate /dev/sda4
# PV         VG Fmt  Attr PSize  PFree
# /dev/sda3  vg lvm2 a--  11.17g     0
# /dev/sda4     lvm2 ---  <2.42g <2.42g
sudo vgcreate vg-db /dev/sda4
# PV         VG    Fmt  Attr PSize  PFree
# /dev/sda3  vg    lvm2 a--  11.17g    0
# /dev/sda4  vg-db lvm2 a--   2.41g 2.41g
sudo lvcreate -l100%FREE vg-db -n data
# PV         VG    Fmt  Attr PSize  PFree
# /dev/sda3  vg    lvm2 a--  11.17g    0
# /dev/sda4  vg-db lvm2 a--   2.41g    0
sudo lvs
# LV   VG    Attr       LSize
# root vg    -wi-ao---- 11.17g
# data vg-db -wi-a-----  2.41g
ls /dev/mapper/ | grep data
# vg--db-data
sudo mkfs -t ext4 /dev/mapper/vg--db-data

sudo mkdir /var/lib/mysql
sudo mount -t ext4 /dev/mapper/vg--db-data /var/lib/mysql
sudo rm -rf /var/lib/mysql/lost+found

cat /etc/fstab | grep "^[^#;]"
sudo cp /etc/fstab{,.original}
echo '/dev/mapper/vg--db-data /var/lib/mysql  ext4  errors=remount-ro  0  1' | sudo tee -a /etc/fstab > /dev/null

sudo reboot
