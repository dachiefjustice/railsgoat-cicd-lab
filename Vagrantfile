# -*- mode: ruby -*-
# vi: set ft=ruby :

# Install common tools (git, tmux, curl), and dependency for railsgoat CI/CD lab: libmysqlclient-dev
# Add Jenkins key, install Jenkins dependencies + Jenkins
# Add an /etc/hosts entry to work arachni "no scanning on localhost" issue
# Install Docker + dependencies, add Docker key
$privileged_provisioning = <<PRIVILEGED_PROV
# Install common tools, prereqs for later installation, railsgoat dependency
apt-get install -y tmux git curl apt-transport-https ca-certificates software-properties-common libmysqlclient-dev

# Add keys for Docker and Jenkins repos
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
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

# Install Docker Compose -- this installs a specific point-in-time version (not "omnifresh")
curl -L https://github.com/docker/compose/releases/download/1.19.0-rc3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Make a hostfile entry for this machine, arachni no-localhost-scan workaround
echo "127.0.0.1       railsgoat-lab" >> /etc/hosts
PRIVILEGED_PROV

# Set up railsgoat (https://github.com/OWASP/railsgoat)
$nonprivileged_provisioning = <<NONPRIVILEGED_PROV
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -L https://get.rvm.io | bash -s stable --autolibs=3 --ruby=2.4.3
git clone https://github.com/OWASP/railsgoat.git
cd railsgoat
source ~/.rvm/scripts/rvm
gem install bundler
bundle install
rails db:setup
NONPRIVILEGED_PROV

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "ubuntu/xenial64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  
  # Forward railsgoat (3000), Jenkins (8080), and arachni (9292) web interfaces to the host
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8080, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 9292, host: 9292, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "./dataexchange", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "4096"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
  
  # First do the provisioning with root privs
  config.vm.provision "shell", inline: $privileged_provisioning, privileged: true
  
  # Then user-specific provisioning
  config.vm.provision "shell", inline: $nonprivileged_provisioning, privileged: false
end
