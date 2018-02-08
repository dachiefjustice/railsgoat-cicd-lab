# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install common tools (git, tmux, curl)
# Add Jenkins key, install Jenkins dependencies + Jenkins
# Add Docker key, install Docker + dependencies, set up Docker for use without sudo
$privileged_provisioning = <<PRIVILEGED_PROV
# Install common tools, prereqs for later installation, railsgoat dependency
apt-get install -y tmux git curl apt-transport-https ca-certificates software-properties-common 

# Add keys for Docker and Jenkins repos
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add repos for Jenkins, Docker
echo "
## Added via Vagrant provisioning for Jenkins LTS releases
deb https://pkg.jenkins.io/debian-stable binary/" >> /etc/apt/sources.list
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Install Jenkins and Docker after adding the appropriate repos
apt-get update
apt-get install -y jenkins docker-ce

# Set Docker up for use without sudo
groupadd docker
usermod -aG docker vagrant

# Install Docker Compose -- this installs a specific version (not the latest) 
curl -L https://github.com/docker/compose/releases/download/1.19.0-rc3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
PRIVILEGED_PROV

# Set up railsgoat with Docker and Docker Compose, to be run as vagrant user after Docker + Docker Compose setup
$railsgoat_docker_provisioning = <<RAILSGOAT_DOCKER_PROV
git clone https://github.com/OWASP/railsgoat.git
cd railsgoat
docker-compose build
docker-compose run web rails db:setup
RAILSGOAT_DOCKER_PROV

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

  # Forward railsgoat (3000), Jenkins (8080), and arachni (9292) web interfaces to the host
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 9292, host: 9292, host_ip: "127.0.0.1"

  # Plenty of RAM, arachni + RailsGoat need it
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

  # First do the provisioning with root privs
  config.vm.provision "shell", inline: $privileged_provisioning, privileged: true
 
  # Kill SSH connections, forcing Vagrant to relog before Docker provisioning (ensures correct user/group perms)
  config.vm.provision "shell",
	  inline: "ps aux | grep 'sshd:' | awk '{print $2}' | xargs kill", privileged: true

  # Prepare the lab environment
  config.vm.provision "shell", inline: $docker_compose_provisioning, privileged: false
end
