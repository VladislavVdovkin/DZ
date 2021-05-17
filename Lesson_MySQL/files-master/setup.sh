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

if [ $id -eq 0 ]; then  mysql --defaults-file=/home/vagrant/my.cnf -e "CREATE DATABASE bet;"; mysql --defaults-file=/home/vagrant/my.cnf -D bet < /vagrant/bet.dmp; mysql --defaults-file=/home/vagrant/my.cnf  -e  "CREATE USER 'repl'@'%' IDENTIFIED BY 'Otus%ReplicationPassword2020';"; mysql --defaults-file=/home/vagrant/my.cnf  -e  "GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'Otus%ReplicationPassword2020';"; mysqldump  --defaults-file=/home/vagrant/my.cnf --all-databases --triggers --routines --master-data --ignore-table=bet.events_on_demand --ignore-table=bet.v_same_event  > /home/vagrant/master.sql; fi


