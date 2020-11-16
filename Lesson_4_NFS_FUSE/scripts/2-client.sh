#!/bin/bash

#Команды будут выполняться из под root
sudo -i
#Устанавливаем необходимые пакеты на сервер
yum install -y nfs-utils
#Включаем и запускаем firewalld
systemctl enable firewalld
systemctl start firewalld
#Добавляем запись в fstab для автоматического монтирования
echo "192.168.10.10:/usr/shared /mnt nfs rw,vers=3,sync,proto=udp,rsize=32768,wsize=32768 0 0" >> /etc/fstab
#Монтируем указанный в fstab каталог в /mnt
mount /mnt/