# -- mode: ruby --
# vi: set ft=ruby :

Vagrant.configure("2") do |config|   
    if Vagrant.has_plugin? "vagrant-vbguest"
      config.vbguest.no_install  = true
      config.vbguest.auto_update = false
      config.vbguest.no_remote   = true
    end
  
    config.vm.define :ubuntuServer do |ubuntuServer|
      ubuntuServer.vm.box = "bento/ubuntu-22.04"
      ubuntuServer.vm.network :private_network, ip: "192.168.100.100"
      ubuntuServer.vm.hostname = "ubuntuServer"
      ubuntuServer.vm.provision "shell", path: "init.sh"
      ubuntuServer.vm.synced_folder "./sharedFolder", "/home/vagrant/sharedFolder"
      ubuntuServer.vm.provider "virtualbox" do |v|
        v.cpus = 2
        v.memory = 4072
      end
    end
  end