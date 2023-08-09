# -*- mode: ruby -*-
# vi: set ft=ruby :

# Update the RailsGoat submodule (run as non-privileged vagrant user)
$railsgoat_submodule_init = <<RAILSGOAT_SUBMOD_INIT
cd /vagrant
git submodule update --init --recursive --remote
RAILSGOAT_SUBMOD_INIT

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.hostname = "railsgoat-cicd-lab"
  
  # Forward railsgoat (3000) and Jenkins (8080) web interfaces to the host
  # IMPORTANT: for security, only expose RailsGoat (deliberately vulnerable) to the host machine
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  
  # Explicitly follow Vagrant default, replace insecure key with a generated key
  config.ssh.insert_key = true

  # Plenty of RAM, arachni + RailsGoat need it
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end
  
  # Set up lab environment with Ansible
  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.playbook = "playbook-vagrant.yml"
  end
  
  # Update/initialize RailsGoat submodule
  # config.vm.provision "shell", inline: $railsgoat_submodule_init, privileged: false
end
