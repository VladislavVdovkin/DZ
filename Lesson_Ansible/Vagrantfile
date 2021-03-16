# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :host1 => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.159'
  }
  #:host2 => {
   #     :box_name => "centos/7",
   #     :ip_addr => '192.168.11.151'
  #}
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          box.vm.network "forwarded_port", guest: 8080, host: 81

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.customize ["modifyvm", :id, "--cpus", "4"]
            vb.customize ["modifyvm", :id, "--memory", "512"]
            # Подключаем дополнительные диски
            #vb.customize ['createhd', '--filename', second_disk, '--format', 'VDI', '--size', 5 * 1024]
            #vb.customize ['storageattach', :id, '--storagectl', 'IDE', '--port', 0, '--device', 1, '--type', 'hdd', '--medium', second_disk]
          end

          box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd
            #yum install -y epel-release
          SHELL

          box.vm.provision "ansible" do |ansible|
            ansible.playbook = "playbook/web.yml"
            ansible.become = "true"
          end

      end
  end
end
