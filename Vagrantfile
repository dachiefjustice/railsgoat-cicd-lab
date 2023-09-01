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

  ## To access RailsGoat from your Vagrant host host:
  ##   1) Uncomment the config.vm.network "forwarded_port" line below to open port 3002 
  ##   2) Apply the configuration: run `vagrant reload`
  ##   3) Run the hold-open job in Jenkins to start RailsGoat on port 3002
  ##   4) Point your browser or other HTTP tool at http://localhost:3002
  # config.vm.network "forwarded_port", guest: 3002, host: 3002, host_ip: "127.0.0.1"
  
  ##### PROVISIONING #####
  config.vm.provision "ansible_local" do |ansible|
    ansible.install = true
    ansible.playbook = "playbook-vagrant.yml"
  end
  config.vm.post_up_message = "RailsGoat CI/CD box. Homepage: https://github.com/dachiefjustice/railsgoat-cicd-lab"

  # Windows-host specific workaround for ansible_local provisioner to use the project's ansible.cfg
  config.vm.synced_folder ".", "/vagrant",  mount_options: ["dmode=775,fmode=755"]
end
