# RailsGoat CI/CD Lab
This free and open-source lab teaches developers and security practitioners how to integrate static analysis (SAST) and dynamic analysis (DAST) into a Jenkins CI/CD pipeline using infrastructure-as-code. It's based on [RailsGoat](https://github.com/OWASP/railsgoat/), an intentionally-vulnerable Rails app intended for training.

## Ways To Use This Lab
- Follow the [walkthrough](docs/lab-walkthrough.md). You'll deploy a Jenkins server and run jobs to perform vulnerability analysis. The lab covers SAST (with [semgrep](https://semgrep.dev/) and [brakeman](https://brakemanscanner.org/)) and DAST (with [ZAP](https://www.zaproxy.org/)).
- Adapt the lab's code for your own purposes. It models these patterns:
  - Using Ansible to deploy and provision Jenkins (including custom plugin selection)
  - Using Docker and Docker Compose within declarative `Jenkinsfile`s to automate vulnerability analysis
- Learn by reading the lab's source code (explanatory comments are sprinkled throughout)

# Lab Usage
Set up a machine meeting these prerequisites:
- Vagrant ([install instructions](https://developer.hashicorp.com/vagrant/docs/installation))
- Virtualbox ([install instructions](https://www.virtualbox.org/wiki/Downloads))
- Git ([install instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- A browser on your Vagrant host machine
- ~15GB of disk space for the lab VM
- 6GB+ of physical RAM (8GB+ is better)
- Bandwidth to download lab environment components

Then get the code and launch the lab environment:
```sh
git clone https://github.com/dachiefjustice/railsgoat-cicd-lab.git
cd railsgoat-cicd-lab
vagrant up
```

Once `vagrant up` is done jump to the [lab walkthrough](docs/lab-walkthrough.md).

# Lab Tips
- If you want to run RailsGoat and access it directly from your browser:
  1) Uncomment the line in the `Vagrantfile` that looks like `config.vm.network "forwarded_port", guest: 3002, host: 3002, host_ip: "127.0.0.1"`
  2) Run `vagrant reload`
  3) Create and run a Jenkins job from the [hold-open Jenkinsfile](sec-tests/hold-open/Jenkinsfile).
  4) Open http://localhost:3002 in your browser (or other HTTP tools)
- Keep an eye on the VM's resource usage and processes using `htop`:
```sh
vagrant ssh
htop
```
- You can adjust how much RAM the VM uses in the `Vagrantfile`:
```ruby
config.vm.provider "virtualbox" do |vb|
  vb.memory = "6144" # for 6GB of RAM
end
```

To apply the changes run `vagrant reload` after adjusting this or other settings in the `Vagrantfile`.
- Tested on Linux and Windows with current versions of Vagrant and Virtualbox; should work on Mac OS as well

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

# Credits
Special thanks to the authors and contributors of key lab components:
- [RailsGoat](https://github.com/OWASP/railsgoat/)
- [ZAP](https://www.zaproxy.org/)
- [semgrep](https://semgrep.dev/)
- [brakeman](https://brakemanscanner.org/)
- [Jeff Geerling's Jenkins Ansible role](https://github.com/geerlingguy/ansible-role-jenkins)