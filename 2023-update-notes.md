# Changes made
- Updated base box to Ubuntu 22.04
- Updated Jenkins version to latest stable version
- Updated VM hostname

# Problems discovered
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

## Arachi scan is failing
```sh
docker run -v /var/lib/jenkins/workspace/arachni_master/sec-tests/arachni:/arachni_vol arachni:jenkins-arachni-master-2 arachni_reporter /arachni_vol/arachni_railsgoat_report.afr --reporter=html:outfile=/arachni_vol/arachni-railsgoat-quickscan-report.html.zip
```
"Report does not exist: /arachni_vol/arachni_railsgoat_report.afr"

# Improvement Ideas
- Update provisioning to use ansible-local
- Update docker-compose to latest
- Update arachni to latest
- Re-take screenshots