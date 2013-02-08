#-*- mode: ruby -*-
# vi: set ft=ruby :

# See the online documentation at vagrantup.com for a reference on this file format.
Vagrant::Config.run do |config|

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Uncomment this option to start VM with a GUI, if you run in a serious trouble.
  # config.vm.boot_mode = :gui

  # Production and dev http ports.
  config.vm.forward_port 80, 3000
  config.vm.forward_port 81, 3001

  # bind source code to /play in addition to /vagrant
  # all code should use /play, because we have no vagrant in production environment, and it would be weird to keep /vagrant folder there
  config.vm.share_folder "play", "/play", "."

  # Enable and configure the chef solo provisioner
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks']
    chef.roles_path = 'roles'
    chef.add_role('dev')
  end

end
