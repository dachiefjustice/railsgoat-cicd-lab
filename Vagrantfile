# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install lab component prereqs
$install_prereqs = <<INSTALL_TOOL_PREREQS
apt-get update && apt-get install -y tmux git curl apt-transport-https \
  ca-certificates software-properties-common default-jre-headless
INSTALL_TOOL_PREREQS

# Install Docker CE
$install_configure_docker = <<INSTALL_DOCKER
# Add key for Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add repo for Docker
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Install Docker + Docker-Compose
apt-get update && apt-get install -y docker-ce docker-compose-plugin

# Set Docker up for use without sudo
groupadd docker
usermod -aG docker vagrant
INSTALL_DOCKER

# Install + configure Jenkins
$install_configure_jenkins = <<JENKINS_INSTALL
# From https://www.jenkins.io/doc/book/installing/linux/#debianubuntu
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add

echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update && apt-get install -y jenkins

# Add jenkins user to docker group (assumes group exists)
usermod -aG docker jenkins

# Bounce jenkins service so Jenkins can run Docker commands
systemctl restart jenkins.service
JENKINS_INSTALL

# Lab setup (to be run as non-privileged vagrant user)
# Ensures the RailsGoat submodule is updated
$railsgoat_submodule_init = <<RAILSGOAT_SUBMOD_INIT
cd /vagrant
git submodule update --init --recursive --remote
RAILSGOAT_SUBMOD_INIT

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
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
  
  # Install prereqs
  config.vm.provision "shell", inline: $install_prereqs, privileged: true
  
  # Install + configure Docker, Docker-Compose
  config.vm.provision "shell", inline: $install_configure_docker, privileged: true

  # Install + configure Jenkins 
  config.vm.provision "shell", inline: $install_configure_jenkins, privileged: true
  
  # Update/initialize RailsGoat submodule
  config.vm.provision "shell", inline: $railsgoat_submodule_init, privileged: false
end
