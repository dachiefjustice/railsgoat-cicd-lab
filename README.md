# RailsGoat CI/CD Lab
This lab teaches developers and security people how to integrate static analysis (SAST) and dynamic analysis (DAST) into a CI/CD pipeline. It demonstrates patterns you can use to perform vulnerability analysis in your own pipelines.

It's based on [OWASP RailsGoat](https://github.com/OWASP/railsgoat/), an intentionally-vulnerable Rails app intended for training. Props to the RailsGoat authors and contributors!

# Usage
## Prerequisites
- Vagrant ([install instructions](https://developer.hashicorp.com/vagrant/docs/installation))
- Virtualbox ([install instructions](https://www.virtualbox.org/wiki/Downloads))
- Git ([install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- A browser on your Vagrant host machine
- This repo cloned/forked on your Vagrant host
- ~15GB of disk space for the lab VM
- 6GB+ of RAM
- Bandwidth to download lab environment components

## Create VM
```sh
git clone https://github.com/dachiefjustice/railsgoat-cicd-lab.git
cd railsgoat-cicd-lab
vagrant up
```

Once `vagrant up` is done jump to the [lab walkthrough](docs/lab-walkthrough.md).

# Notes & Tips
- Read through the lab's source code, there are explanatory comments sprinkled throughout
- Tested on Linux and Windows with current versions of Vagrant and Virtualbox; should work on Mac OS as well
- If you want to run RailsGoat and access it directly from your browser:
  1) Uncomment the line in the `Vagrantfile` that looks like `config.vm.network "forwarded_port", guest: 3002, host: 3002, host_ip: "127.0.0.1"`
  2) Run `vagrant reload`
  3) Create and run a Jenkins job from the [zap-hold-open Jenkinsfile](sec-tests/zap-hold-open/Jenkinsfile).
  4) Open http://localhost:3002 in your browser (or other HTTP tools)
- You can adjust how much RAM the VM uses in the `Vagrantfile`:
```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "4096"
end
```

# Lab Tech Stack
| Software                  | Purpose                                 | 
|---------------------------|-----------------------------------------|
| Virtualbox                | Hypervisor                              |
| Vagrant                   | VM management                           | 
| Ansible                   | VM provisioning                         |
| Debian Linux              | Main OS                                 |
| Alpine Linux              | Support containers                      |
| Git                       | Move code and tools arond               |
| Jenkins                   | Build/deploy/test RailsGoat             |
| Docker + Docker Compose   | Automating pipeline tasks               |
| semgrep, brakeman         | Static analysis of RailsGoat            |
| ZAP                       | Dynamic analysis of RailsGoat           |