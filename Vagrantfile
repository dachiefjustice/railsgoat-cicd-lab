Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "railsgoat-cicd-lab"
  
  # Forward Jenkins (8080) web interface to the host
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # Plenty of RAM
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "6144"
  end
  
  # Set up lab environment with Ansible
  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.playbook = "playbook-vagrant.yml"
  end
end
