#!/bin/bash

sudo -i
# Install mdadm
yum install -y mdadm smartmontools hdparm gdisk
# Zero-superblocks
mdadm --zero-superblock --force /dev/sd{b,c,d,e,f}
# Make Raid 5
mdadm --create --verbose /dev/md0 -l 5 -n 5 /dev/sd{b,c,d,e,f}
# Make dir for mdadm
mkdir /etc/mdadm
# Create mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
# Make GPT parts
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
# Make fs on GPT parts
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done
# Mount GPT parts
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

