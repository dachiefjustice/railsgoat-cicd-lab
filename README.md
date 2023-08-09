# RailsGoat CI/CD Lab
This lab teaches developers and security people how to integrate static analysis (SAST) and dynamic analysis (DAST) into a CI/CD pipeline. It models patterns you can use to vulnerability analysis in your own pipelines!

This lab uses [OWASP RailsGoat](https://github.com/OWASP/railsgoat/), an intentionally-vulnerable Rails app intended for training. Props to the wonderful folks working on that project!

This lab was originally released in 2018; it's currently undergoing updates in 2023.

# Usage
## Prerequisites
Make sure you've got:
- Vagrant and a compatible hypervisor (tested with Virtualbox on Linux and Windows)
- A browser on your Vagrant host machine
- This repo cloned to your Vagrant host
- Bandwidth for the lab's automation

Then:
```sh
git clone https://github.com/dachiefjustice/railsgoat-cicd-lab.git
vagrant up
```

Now jump to the [lab walkthrough](docs/lab-walkthrough.md).

## Tech Stack
The lab environment is heavily automated. Key elements:
- [OWASP RailsGoat](https://github.com/OWASP/railsgoat/), (the app this lab is based around)
- Vagrant, Virtualbox, and Ansible (environment provisioning)
- Jenkins (manage RailsGoat builds and tests)
- Git (moving tools and code around)
- Docker + Docker Compose (automate pipeline tasks)
- Brakeman (static analysis of RailsGoat)
- OWASP ZAP (dynamic analysis of RailsGoat)
- Alpine Linux (some containers)
- Ubuntu Linux (main VM)