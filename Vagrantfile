Vagrant.configure("2") do |config|
  ##### CORE CONFIG #####
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = "railsgoat-cicd-lab"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096" # Plenty of RAM (for Jenkins + RailsGoat + ZAP together)
  end
  
  ##### NETWORKING/PORT FORWARDING #####
  # Forward Jenkins (8080) web interface to the host
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # To access RailsGoat from your host's browser/tools:
  #   1) Run the zap-hold-open job in Jenkins
  #   2) Uncomment the line below this one 
  # config.vm.network "forwarded_port", guest: 3002, host: 3002, host_ip: "127.0.0.1"
  
  ##### PROVISIONING #####
  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.playbook = "playbook-vagrant.yml"
  end

  # Windows-host specific workaround for ansible_local provisioner to use the project's ansible.cfg
  config.vm.synced_folder ".", "/vagrant",  mount_options: ["dmode=775,fmode=755"]
end
