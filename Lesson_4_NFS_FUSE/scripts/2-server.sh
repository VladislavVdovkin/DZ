#!/bin/bash

#Команды будут выполняться из под root
sudo -i
#Устанавливаем необходимые пакеты на сервер
yum install -y nfs-utils
#Включаем сервисы необходимые для nfs сервера
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable rpc-statd
systemctl enable nfs-idmapd
#Запускаем сервисы необходимые для nfs сервера
systemctl start rpcbind
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd
#Создаем дирректорию которую расшариваем
mkdir -p /usr/shared/
#Даём права данной дирректории
chmod 0777 /usr/shared/
#Конфигурируем exports
cat << EOF | sudo tee /etc/exports
/usr/shared/ 192.168.10.0/24(rw,sync)
EOF
#Применяем изменения
exportfs -ra
#Включаем и запускаем firewalld
systemctl enable firewalld
systemctl start firewalld
#Включаем сервисы
firewall-cmd --permanent --add-service=nfs3
firewall-cmd --permanent --add-service=mountd
firewall-cmd --permanent --add-service=rpc-bind
firewall-cmd --reload
#Создаем папку uploads в расшареной дирректории
mkdir /usr/shared/uploads

