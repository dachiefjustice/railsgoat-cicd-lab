# Problems discovered
## Ruby 6+ host header checks
Ruby 6 and newer now performs host header checking to defend against DNS rebinding attacks: https://github.com/rails/rails/pull/33145

This causes failures with DAST against RailsGoat via docker-compose. Solution: https://danielabaron.me/blog/rails-blocked-host-docker-fix/

Fixed by allowlisting hostname in [railsgoat/config/environments/development.rb](railsgoat/config/environments/development.rb) and passing hostname via [sec-tests/zap/compose.yaml](sec-tests/zap/compose.yaml).

## Docker Compose volume root permissions (ZAP reporting)
Docker Compose volumes create volumes owned by root, but it's a best practice to use non-root users within containers. To fix this:
- Create an initializer container that runs as root and `chown`s the volume to the UID of the non-root user writing to the volume
- In the container writing to the volume, add a `depends_on` to the initializer container.

## Railsgoat submodule not updating
Automation in various parts of the project updates the railsgoat submodule, but wasn't pulling the latest changes.

Resolved with: `git submodule update --init --recursive --remote`

EDIT: disabled automatically pulling latest RailsGoat upstream due to overriding host-header checking code.

## Git-SCM local repo scanning disabled
The Git SCM plugin started disabling `file://` repos for security reasons.

To resolve it: Ansible provisioning `geerlingguy.jenkins` role -> `jenkins_java_options` = `-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true`

## Arachni scan is failing
```sh
docker run -v /var/lib/jenkins/workspace/arachni_master/sec-tests/arachni:/arachni_vol arachni:jenkins-arachni-master-2 arachni_reporter /arachni_vol/arachni_railsgoat_report.afr --reporter=html:outfile=/arachni_vol/arachni-railsgoat-quickscan-report.html.zip
```
"Report does not exist: /arachni_vol/arachni_railsgoat_report.afr"

EDIT: discarded in favor of ZAP

# TODOs
## In progress
[ ] Redo lab instructions
[ ] Re-take screenshots

## Completed
~~[x] Update base box to latest Ubuntu LTS~~
[x] Update base box to latest stable Debian
[x] Update to latest stable Jenkins
[x] Update VM hostname
[x] Update provisioning to use Ansible
[x] Allow using `file://` in Jenkins jobs
[x] Update docker-compose to latest
~~[x] Update arachni to latest~~
[x] Add ZAP scans
[x] Add Semgrep job

## Discarded
[ ] Fix Arachni scan (using ZAP instead; more reliably maintained, problems with Arachni Chrome/Chromedriver version)

# Future ideas
[ ] Add Nuclei job