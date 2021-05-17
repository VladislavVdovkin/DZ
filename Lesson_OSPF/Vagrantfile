
MACHINES = {
  :R1 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '10.100.1.1', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "r1-r2"},
                   {ip: '10.100.2.1', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "r1-r3"},
                ]
  },
  
  :R2 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '10.100.1.2', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "r1-r2"},
                   {ip: '10.100.3.2', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "r2-r3"},
                ]
  },

  :R3 => {
        :box_name => "centos/7",
        :net => [
                   {ip: '10.100.2.2', adapter: 2, netmask: "255.255.255.0", virtualbox__intnet: "r1-r3"},
                   {ip: '10.100.3.1', adapter: 3, netmask: "255.255.255.0", virtualbox__intnet: "r2-r3"},

                ]
  },

}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end

        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provider "virtualbox" do |v|
         v.memory = 512
         v.cpus = 2
        end

    end

  end

  config.vm.provision "ansible" do |ansible|
             ansible.playbook = "provisioning/playbook.yml"
             ansible.become = "true"
  end
end
