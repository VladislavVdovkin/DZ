# -*- mode: ruby -*-
# vim: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.box_check_update = true
	
  config.vm.define "master", primary: true do |w|
    w.vm.hostname = 'master'
    w.vm.network "private_network", ip: "192.168.50.10"
	w.vm.provider :virtualbox do |v|
		v.name = "master"
		v.customize ["modifyvm", :id, "--cpus", 2, "--memory", "2048"]
    end
  

  w.vm.provision "shell", inline: <<-SHELL
    
    yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm epel-release -y; yum install Percona-Server-server-57 -y

  SHELL

  w.vm.provision "file", source: "./files-master/01-base.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-master/02-max-connections.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-master/03-performance.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-master/04-slow-query.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-master/05-binlog.cnf", destination: "/tmp/"

  w.vm.provision "shell", path: "./files-master/setup.sh"

  end

  config.vm.define "slave", primary: true do |w|
    w.vm.hostname = 'slave'
    w.vm.network "private_network", ip: "192.168.50.20"
	w.vm.provider :virtualbox do |v|
		v.name = "slave"
		v.customize ["modifyvm", :id, "--cpus", 2, "--memory", "2048"]

    end
  
  w.vm.provision "shell", inline: <<-SHELL
    
    yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm epel-release -y; yum install Percona-Server-server-57 sshpass -y

  SHELL

  w.vm.provision "file", source: "./files-slave/01-base.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-slave/02-max-connections.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-slave/03-performance.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-slave/04-slow-query.cnf", destination: "/tmp/"

  w.vm.provision "file", source: "./files-slave/05-binlog.cnf", destination: "/tmp/"

  w.vm.provision "shell", path: "./files-slave/setup.sh"

  end

end

