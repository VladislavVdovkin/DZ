#!/usr/bin/env bash

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo systemctl reload sshd

sudo timedatectl set-timezone Europe/Moscow

cp /tmp/*.cnf /etc/my.cnf.d/

sudo systemctl start mysql

password=$(cat /var/log/mysqld.log | grep 'root@localhost:' | awk '{print $11}')

echo -e "[client]\n\ruser=\"root\"\n\rpassword=\"$password\"" > /home/vagrant/my.cnf

id=1

mysql --defaults-file=/home/vagrant/my.cnf  -e "ALTER USER USER() IDENTIFIED BY '1UnnZ6^%010#dAN';" --connect-expired-password

if [ $? -eq 0 ]; then  id=0; fi

password='1UnnZ6^%010#dAN'

echo -e  "[client]\n\ruser=\"root\"\n\rpassword=\"$password\"" > /home/vagrant/my.cnf

sshpass -p "vagrant" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@192.168.50.10:/home/vagrant/master.sql /home/vagrant

if [ $id -eq 0 ]; then  mysql --defaults-file=/home/vagrant/my.cnf -e "CREATE DATABASE bet;"; mysql --defaults-file=/home/vagrant/my.cnf -e "reset master;"; mysql --defaults-file=/home/vagrant/my.cnf -D bet < /home/vagrant/master.sql; mysql --defaults-file=/home/vagrant/my.cnf -e "CHANGE MASTER TO MASTER_HOST = '192.168.50.10', MASTER_PORT = 3306, MASTER_USER = 'repl', MASTER_PASSWORD = 'Otus%ReplicationPassword2020', MASTER_AUTO_POSITION = 1;"; mysql --defaults-file=/home/vagrant/my.cnf -e "START SLAVE;"; fi  
