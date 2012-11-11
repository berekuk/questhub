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

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  # Enable and configure the chef solo provisioner
  config.vm.provision :chef_solo do |chef|

    chef.cookbooks_path = ['cookbooks']
    chef.json = {
      'dev' => true
    }

    # Tell chef what recipe to run. In this case, the `vagrant_main` recipe
    # does all the magic.
    chef.add_recipe 'apt-repo'
    chef.add_recipe 'ubic'
    chef.add_recipe 'mongodb'
    chef.add_recipe 'perl'
    chef.add_recipe 'play-perl'

    require 'json'
    open('dna.json', 'w') do |f|
      chef.json[:run_list] = chef.run_list
      f.write chef.json.to_json
    end
    open('.cookbooks_path.json', 'w') do |f|
      f.puts JSON.generate(
        [chef.cookbooks_path].flatten.map{|x| x}
      )
    end
  end

end
