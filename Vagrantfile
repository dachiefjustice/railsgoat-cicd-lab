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

$install_jenkins_in_vm = <<JENKINS_INSTALL
# From https://jenkins.io/doc/book/installing/#debian-ubuntu
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins

JENKINS_INSTALL

# Copy the docker-compose lab into ~, and build it
$docker_compose_provisioning = <<DOCKER_COMPOSE_PROV
cp -r /vagrant/railsgoat-lab ~
cd ~/railsgoat-lab
docker-compose build
DOCKER_COMPOSE_PROV

Vagrant.configure("2") do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Forward railsgoat (3000), arachni (9292), Jenkins (8080) web interfaces to the host
  # IMPORTANT: for security, only expose RailsGoat (deliberately vulnerable) to the host machine
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 9292, host: 9292, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"

  # Plenty of RAM, arachni + RailsGoat need it
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

  # First do the provisioning with root privs
  config.vm.provision "shell", inline: $privileged_provisioning, privileged: true
  
  # Install Jenkins with root privs
  config.vm.provision "shell", inline: $install_jenkins_in_vm, privileged: true
  
  # Kill SSH connections, forcing Vagrant to relog before Docker provisioning (ensures correct user/group perms)
  config.vm.provision "shell",
	  inline: "ps aux | grep 'sshd:' | awk '{print $2}' | xargs kill", privileged: true

  # Prepare the lab environment
  #config.vm.provision "shell", inline: $docker_compose_provisioning, privileged: false
end
