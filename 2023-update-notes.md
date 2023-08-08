# Problems discovered
## Railsgoat submodule not updating
Automation in various parts of the project updates the railsgoat submodule, but wasn't pulling the latest changes.

Resolved with: `git submodule update --init --recursive --remote`

## Git-SCM local repo scanning disabled
The Git SCM plugin started disabling `file://` repos for security reasons.

To resolve it:

```sh
vagrant ssh
sudo systemctl edit jenkins.service

# Tell the GitSCM plugin to allow local repositories by adding:
[Service]
Environment="JAVA_OPTS=-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true"

sudo systemctl restart jenkins.service
```

## Arachni scan is failing
```sh
docker run -v /var/lib/jenkins/workspace/arachni_master/sec-tests/arachni:/arachni_vol arachni:jenkins-arachni-master-2 arachni_reporter /arachni_vol/arachni_railsgoat_report.afr --reporter=html:outfile=/arachni_vol/arachni-railsgoat-quickscan-report.html.zip
```
"Report does not exist: /arachni_vol/arachni_railsgoat_report.afr"

# TODOs
[x] Update base box to latest Ubuntu LTS
[x] Update to latest stable Jenkins
[x] Update VM hostnamed
[x] Update provisioning to use Ansible
[x] Allow using `file://` in Jenkins jobs
[x] Update docker-compose to latest
[x] Update arachni to latest
[ ] Fix Arachni scan
[ ] Re-test lab instructions
[ ] Re-take screenshots

# Future ideas
[ ] Add Nuclei job
[ ] Add Semgrep job