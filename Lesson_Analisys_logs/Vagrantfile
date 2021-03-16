# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :web => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.150',
        :memory => '400',
        :cpu => '1'
  },
  :log => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.151',
        :memory => '400',
        :cpu => '1'
  },
  :lognginx => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.152',
        :memory => 4096,
        :cpu => 4
  }
}

Vagrant.configure("2") do |config|

  config.vm.provision "ansible" do |ansible|
    #ansible.verbose = "vvv"
    ansible.playbook = "playbook.yml"
    ansible.become = "true"
  end

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          box.vm.network "private_network", ip: boxconfig[:ip_addr]

          box.vm.provider :virtualbox do |vb|
            vb.memory = boxconfig[:memory]
            vb.cpus = boxconfig[:cpu]
          end
      end
  end
end