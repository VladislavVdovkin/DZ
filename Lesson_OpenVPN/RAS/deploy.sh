#!/bin/sh
yum install -y wget vagrant openvpn
mkdir ovpn_test_lawn && cd ovpn_test_lawn
wget https://github.com/lawn58/openvpn/blob/master/Vagrantfile
vagrant up ovpn
mkdir client
vagrant scp :/home/vagrant/output/* client/
cd client
sudo openvpn client.conf
