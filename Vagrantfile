# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install common tools (git, tmux, curl)
# Set up Docker, Docker Compose, and dependencies
$privileged_provisioning = <<PRIVILEGED_PROV
# Install common tools, prereqs for later installation, railsgoat dependency
apt-get install -y tmux git curl apt-transport-https ca-certificates software-properties-common 

# Add key for Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add repo for Docker
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Install Docker 
apt-get update
apt-get install -y docker-ce

# Set Docker up for use without sudo
groupadd docker
usermod -aG docker vagrant

# Install Docker Compose -- this installs a specific version (not the latest) 
curl -L https://github.com/docker/compose/releases/download/1.19.0-rc3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
PRIVILEGED_PROV

# Install + configure Jenkins, needs to run as root
$install_jenkins_in_vm = <<JENKINS_INSTALL
# From https://jenkins.io/doc/book/installing/#debian-ubuntu
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins

# Add jenkins user to docker group (assumes group exists)
usermod -aG docker jenkins

# Bounce jenkins service to apply docker group change
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

  # First do the provisioning with root privs
  config.vm.provision "shell", inline: $privileged_provisioning, privileged: true
  
  # Install Jenkins with root privs
  config.vm.provision "shell", inline: $install_jenkins_in_vm, privileged: true
  
  # Prepare the lab environment
  config.vm.provision "shell", inline: $lab_setup, privileged: false
end
