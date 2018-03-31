# -*- mode: ruby -*-
# vi: set ft=ruby :

# Privileged common tools, lab component prereq installation
$install_prereqs = <<INSTALL_TOOL_PREREQS
apt-get update && apt-get install -y tmux git curl apt-transport-https ca-certificates software-properties-common 
INSTALL_TOOL_PREREQS

# Privileged Docker CE installation
$install_configure_docker = <<INSTALL_DOCKER
# Add key for Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add repo for Docker
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Install Docker 
apt-get update && apt-get install -y docker-ce

# Set Docker up for use without sudo
groupadd docker && usermod -aG docker vagrant
INSTALL_DOCKER

# Privileged Docker Compose install 
$install_docker_compose = <<INSTALL_DOCKER_COMPOSE
# Install Docker Compose -- this installs a specific version (not the latest) 
curl -L https://github.com/docker/compose/releases/download/1.20.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
INSTALL_DOCKER_COMPOSE

# Privileged install + configure Jenkins, needs to run as root
$install_configure_jenkins = <<JENKINS_INSTALL
# From https://jenkins.io/doc/book/installing/#debian-ubuntu
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update && apt-get install -y jenkins

# Add jenkins user to docker group (assumes group exists)
usermod -aG docker jenkins

# Bounce jenkins service so Jenkins can run Docker commands
systemctl restart jenkins.service
JENKINS_INSTALL

# Lab setup (to be run as non-privileged vagrant user)
#   - Copy railsgoatlab into /home/vagrant
#   - Configure git with vagrant user info
#   - Initialize + set up git repos for arachni_jenkins and brakeman_jenkins
$lab_setup = <<LAB_SETUP
# Copy lab files into homedir
cp -r /vagrant/railsgoat-lab ~

# Set up git
git config --global user.name "Vagrant Lab"
git config --global user.email "vagrantlab@example.com"

# Set up arachni_jenkins
cd ~/railsgoat-lab/arachni_jenkins
git init
git add .
git commit -m 'Initial auto-commit from Vagrant setup'

# Set up brakeman_jenkins
cd ~/railsgoat-lab/brakeman_jenkins
git init
git add .
git commit -m 'Initial auto-commit from Vagrant setup'
LAB_SETUP

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"
  
  # Forward railsgoat (3000) and Jenkins (8080) web interfaces to the host
  # IMPORTANT: for security, only expose RailsGoat (deliberately vulnerable) to the host machine
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  
  # Plenty of RAM, arachni + RailsGoat need it
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end
  
  # Install prereqs
  config.vm.provision "shell", inline: $install_prereqs, privileged: true
  
  # Install + configure Docker
  config.vm.provision "shell", inline: $install_configure_docker, privileged: true

  # Install Docker Compose
  config.vm.provision "shell", inline: $install_docker_compose, privileged: true

  # Install + configure Jenkins 
  config.vm.provision "shell", inline: $install_configure_jenkins, privileged: true
  
  # Prepare the lab environment
  config.vm.provision "shell", inline: $lab_setup, privileged: false
end
