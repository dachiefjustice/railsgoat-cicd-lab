# Lab Walkthrough
## Initial Setup
Open the [README](../README.md) and follow the basic usage instructions to get started:

![Clone and Vagrant Up](screenshots-new/exploration/01-clone-and-vagrant-up.png)

After running `vagrant up` you'll see a lot of output as Vagrant provisions the VM:
1) Vagrant installs Ansible (using the [`ansible_local` provisioner's automatic installation](https://developer.hashicorp.com/vagrant/docs/provisioning/ansible_local#install))
2) Ansible installs and configure Jenkins + Jenkins plugins, Docker, and Docker Compose.

The VM is ready once you return to a shell prompt preceded by a welcome message:
![VM Welcome Message](screenshots-new/exploration/02-vagrant-welcome.png)

## Explore The Lab Environment
### Explore The CLI
Get a shell in the lab machine, and check that you can access the lab's code via `/vagrant` (Vagrant maps this automatically during `vagrant up`). This lab's Jenkins pipelines use the `/vagrant` mapping.

```sh
vagrant ssh
ls -la /vagrant # show the lab's root directory contents
```
![Vagrant SSH and /vagrant](screenshots-new/exploration/03-vagrant-ssh.png)

Check that Jenkins is running with `systemctl status jenkins.service` (press `q` to exit after confirming that Jenkins is loaded):
![Jenkins status](screenshots-new/exploration/04-check-jenkins.png)

Use `htop` to explore system resources and processes (press `q` to exit afterwards):
![htop](screenshots-new/exploration/05-htop.png)

### Explore The Jenkins Web Interface
#### Initial Login
Log into the Jenkins web interface at http://localhost:8080 with the default credentials (`admin/admin`):
![Jenkins login](screenshots-new/exploration/06-jenkins-login-page.png)

### RailsGoat
#### Launch RailsGoat via Jenkins
It's time set up the first Jenkins pipeline! Pipelines are sometimes called jobs -- you'll see both terms used. This lab uses Jenkins pipelines for security analysis.

Start by making a pipeline that runs RailsGoat and ZAP in containers, holding them open together so you can explore RailsGoat. Click `Create a job`:
![Create first Jenkins job](screenshots-new/exploration/07-jenkins-create-first-job.png)

Name the job `hold-RailsGoat-open` (or whatever you like). Select "Multibranch Pipeline" as the job type, and press OK:
![Create hold-RailsGoat-open](screenshots-new/exploration/08-jenkins-create-multibranch-pipeline.png)

On the next screen give the job a display name (whatever you like, `hold-RailsGoat-open` in the screenshot). Add a branch source specifying `file:///vagrant` as the `Project Repository`:
![Add branch source](screenshots-new/exploration/09-jenkins-add-branch-source.png)

Scroll down to the `Build Configuration` section and specify `sec-tests/hold-open/Jenkinsfile` as the `Script Path`. Then press Save:
![Specify Jenkinsfile path](screenshots-new/exploration/10-jenkins-specify-Jenkinsfile-path.png)

After pressing Save, Jenkins scans the repository and starts a build. Click the `#1 (hold-open)` link to open that build:
![Jenkins starts build](screenshots-new/exploration/11-jenkins-scan-multibranch-pipeline.png)

Then click the `Console Output` button:
![Console output](screenshots-new/exploration/12-jenkins-console-output.png)

Scroll to the bottom. Notice that Jenkins is sitting on a line like `hold-open-zap-holdopen-with-railsgoat-1`:
![Holding RailsGoat open](screenshots-new/exploration/13-jenkins-holding-open.png)

This means that Jenkins is running RailsGoat for you. Confirm this by opening a new tab and browsing to http://localhost:3002 and you should see the RailsGoat login page:
![RailsGoat login page](screenshots-new/exploration/14-railsgoat-login-page.png)

From here play around with RailsGoat -- create yourself a test account, log in, and poke around. You can also search for and exploit vulnerabilities manually.

This works because port 3002 is used in the [the job's `compose.yaml`](../sec-tests/hold-open/compose.yaml), and is forwarded in the [project's `Vagrantfile`](../Vagrantfile). This port-forward is restricted to `127.0.0.1` so other machines on your network can't exploit these vulnerabilities (without first compromising your Vagrant host, at least).

#### Hold-Open Job Explainer
Let's walk through this job in detail.

First, the job's purpose: run RailsGoat and ZAP containers together until you stop them by cancelling the job. This lets you browse RailsGoat and manually scan it from ZAP.

Next, the job's pipeline definition: [`sec-tests/hold-open/Jenkinsfile`](../sec-tests/hold-open/Jenkinsfile). The most important section of this `Jenkinsfile`:
```groovy
stage('hold-open') {
    steps {
        // Hold ZAP and RailsGoat open together
        sh 'docker-compose --file $WORKSPACE/sec-tests/hold-open/compose.yaml up zap-holdopen-with-railsgoat'
    }
}
```

Here's what each component of this section does:
- The `hold-open` stage is a descriptively-named [Jenkins stage](https://www.jenkins.io/doc/book/glossary/#stage). Stages group related pipeline steps together; common stage names include variations on `build`, `test`, and `deploy`. Naming stages descriptively is a good practice. Stage names show up in the Jenkins web interface:
![Jenkins pipeline steps](screenshots-new/exploration/jenkins-pipeline-hold-open-step.png)
- The [Jenkins `sh` step](https://www.jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#sh-shell-script) runs a shell script. In this case, it uses `docker-compose up` to run RailsGoat and ZAP containers as defined in [`sec-tests/hold-open/compose.yaml`](../sec-tests/hold-open/compose.yaml).
- [`sec-tests/hold-open/compose.yaml`](../sec-tests/hold-open/compose.yaml) is a [Docker Compose file](https://docs.docker.com/compose/compose-file/03-compose-file/) that defines the components and configuration for RailsGoat and ZAP containers. Docker's networking includes a DNS server that maps service names from the Compose file onto container IP addresses. This lets containers access each other's ports via a static hostname, rather than needing to know each other's dynamically assigned IP addresses.
- `$WORKSPACE` (part of the path to this job's `compose.yaml`) is a Jenkins-defined environment variable holding the absolute path to the "workspace" for this job. A Jenkins workspace contains the job's files and directories. In this case the workspace contains a copy of the lab's source code checked out from the `/vagrant` directory.

### ZAP Baseline Scan
So far we've used the hold-open job to access RailsGoat through a browser. This hold-open job includes a ZAP container which can analyze RailsGoat for vulnerabilities. Let's use this to scan RailsGoat manually.

Get a shell in the VM (`vagrant ssh`) and list the currently running containers (`docker ps`). You'll see two running containers -- one for ZAP, the other for RailsGoat.

You can find the ZAP container from the image name (it will contain `zaproxy`). Copy the ZAP container ID for use in the next command (`94572b01272a` in this example, yours will be different).

```sh
vagrant ssh
docker ps
```
![ZAP container ID](screenshots-new/exploration/15-find-zap-container.png)


Now that you know the ZAP container ID, get a shell in the ZAP container and start a baseline scan:
```sh
docker exec -it your-ZAP-container-ID bash      # get a shell in the ZAP container
./zap-baseline.py -t http://railsgoat-web:3002  # start a baseline scan
```
![ZAP manual baseline scan](screenshots-new/exploration/16-manual-zap-baseline.png)

The scan will finish in a minute or two and find some basic security issues:
![Baseline scan results](screenshots-new/exploration/17-zap-baseline-results.png)

These issues are relatively uninteresting -- no SQL injection, cross-site scripting or other severe vulnerabilities. However, RailsGoat contains these vulnerabilities. Why didn't ZAP find them?

[ZAP's baseline scan](https://www.zaproxy.org/docs/docker/baseline-scan/) performs basic HTTP spidering and analyzes the results passively, rather than performing active or authenticated scanning. ZAP's baseline scan doesn't find many URLs (14 during my testing, which is a small subset of all RailsGoat URLs):
![ZAP small number of URLs](screenshots-new/exploration/18-small-number-of-URLs.png)

ZAP can discover application URLs using two spidering methods:
- The [traditional spider](https://www.zaproxy.org/docs/desktop/addons/automation-framework/job-spider/) makes HTTP requests and parses the resulting HTML for links.
- The [AJAX spider](https://www.zaproxy.org/docs/desktop/addons/ajax-spider/automation/) makes HTTP requests and analyzes the resulting HTML *and* JavaScript by "clicking" links inside a ZAP-managed web browser. Compared with the traditional spider this does a better job discovering URLs in JavaScript-heavy web applications, and is slower and more resource-intensive.

RailsGoat uses a mix of HTML and JavaScript URLs. Most RailsGoat URLs are gated behind authentication. Since ZAP's baseline scan uses the traditional spider without authentication or active scanning, the scan finishes quickly but doesn't find severe or harder-to-discover issues. Later in the lab you will configure ZAP to perform a more comprehensive, authenticated, slower scan.

Back in the browser, cancel the `hold-RailsGoat-open` job:
![Cancel hold-RailsGoat-Open job](screenshots-new/exploration/19-cancel-hold-open-job.png)

Now you've explored the lab environment a bit, and learned:
- How to create a Jenkins job from a `Jenkinsfile`
- The basic structure of a Jenkins pipeline/job
- How default `docker-compose` networking setup allows containers to access each other via hostnames
- How to identify which containers a job uses, and manually execute commands in those containers
- How to manually run a ZAP baseline scan

## Dynamic Analysis (DAST)
### ZAP Baseline Scan

### ZAP Authenticated Scan
TODO: add automated ZAP authenticated scan

## Static Analysis (SAST)
### Semgrep
TODO: add content

### Brakeman
TODO: update content

Now that you've got Jenkins set up, time to analyze the RailsGoat codebase for security issues with Brakeman, a static analyzer that operates against Ruby-on-Rails source code.
1. If you're not logged into the Jenkins UI already, do so at http://localhost:8080 in a browser on the Vagrant host.
2. Create a new job/item in Jenkins. Call it `brakeman` (or something else if you prefer). Make the job a "Multibranch Pipeline" job.
![making brakeman job](screenshots/10_brakemanJobCreation.png)
3. In the job configuration screen, add a Git source repo. By default, Vagrant mounts the project directory (the cloned repo, in this case) from the host to the VM under `/vagrant`. Use that as the source repo for this job (`file:///vagrant`). The source repo contains a ready-made Jenkinsfile for scanning RailsGoat using Brakeman. Tell Jenkins about this by changing the `Build Configuration -> Script Path` field to `sec-tests/brakeman/Jenkinsfile`. 
![brakeman job add repo](screenshots/11_brakemanAddBranchSource.png)
![brakeman job Jenkinsfile path](screenshots/12_brakemanSpecifyJenkinsfilePath.png)
4. When you hit the Save button, Jenkins should scan the repo, find the Jenkinsfile, build a container for Brakeman, and kick off the code scan.
![brakeman job start](screenshots/13_brakemanBuildStarts.png)
5. If all goes well, you should be able to get the HTML report generated by Brakeman in the Jenkins job, from the master branch. If you called the job `brakeman` earlier, it should be under http://localhost:8080/job/brakeman/job/master/
![brakeman job complete](screenshots/14_brakemanSuccesfulRun.png)

## Old Arachni Content
TODO: remove arachni content

Now that you've got Jenkins set up, time to analyze the RailsGoat app for security issues with Arachni, a dynamic web application security scanner that operates over the network. The automation is a bit more in-depth than Brakeman, relying on two running containers (one for RailsGoat, one for Arachni) managed by Docker Compose. The process of setting up the job is similar to Brakeman; start there if you haven't done that yet, since the Brakeman job runs quickly.

1. If you're not logged into the Jenkins UI already, do so at http://localhost:8080 in a browser on the Vagrant host.
2. Create a new job/item in Jenkins. Call it `arachni` (or something else if you prefer). Make the job a "Multibranch Pipeline" job, like before with Brakeman.
![making arachni job](screenshots/15_arachniJobCreation.png)
3. In the job configuration screen, add a Git source repo. By default, Vagrant mounts the project directory (the cloned repo, in this case) from the host to the VM under `/vagrant`. Use that as the source repo for this job (`file:///vagrant`). The source repo contains a ready-made Jenkinsfile for scanning RailsGoat using Arachni. Tell Jenkins about this by changing the `Build Configuration -> Script Path` field to `sec-tests/arachni/Jenkinsfile`. 
![arachni job add repo](screenshots/16_arachniRepoAdd.png)
![arachni job Jenkinsfile path](screenshots/17_arachniBranchSource.png)
4. When you hit the Save button, Jenkins should scan the repo, find the Jenkinsfile, build containers for RailsGoat, Arachni, and scan RailsGoat with Arachni. This will take a while (perhaps 30+ minutes), depending on your Internet speed, RAM allocated to your Vagrant VM, etc. Maybe some more coffee.
![arachni job starts](screenshots/18_arachniBuildStarts.png)
5. Check progress by clicking through the Jenkins UI and viewing the console output for the running build/job. If you called the job `arachni` earlier and this is the first time you're running the build, it should be available at http://localhost:8080/job/arachni/job/master/1/console
![arachni job console](screenshots/19_arachniJobConsole.png)
6. After the job finishes, you should be able to get a zipped HTML report generated by Arachni in the Jenkins job, from the master branch. If you called the job `arachni` earlier, it should be under http://localhost:8080/job/arachni/job/master/
![arachni job complete](screenshots/20_arachniSuccesfulRun.png)

The default scan for this lab uses a subset of Arachni's tests to keep scan times reasonable.

## Lab Exercise & Self-Directed Learning
If you're enjoying this lab, here's a exercise for you: [RailsGoat](https://github.com/OWASP/railsgoat/) contains a set of failing Capybara RSpecs. Try making a Jenkins job that will run these and capture the output in the Jenkins build. Change stuff, see what breaks, try and fix it.

You'll get the most out of this lab if you take time to read the `Jenkinsfile`s, `Dockerfile`s, and `docker-compose.yml` files. Figure out how stuff that's new to you works. The [Jenkins docs](https://jenkins.io/doc/), [Docker docs](https://docs.docker.com/), [Brakeman docs](https://brakemanscanner.org/docs/), and [Arachni wiki](https://github.com/Arachni/arachni/wiki) are excellent resources.

## Under the Hood with Brakeman
TODO: update or delete this section

Some of the stuff going on under the hood with the Brakeman test:

- Why use Alpine Linux for the Brakeman container? It's lightweight, minimizes attack surface, and results in smaller, faster, and cleaner Docker containers than more full-featured Linux distributions.
- The `checkout scm` step in the `Jenkinsfile` copies the source repo configured in Jenkins jobs into the workspace (for later use by the Brakeman container).
- Jenkins sets [a bunch of environment variables](https://wiki.jenkins.io/display/JENKINS/Building+a+software+project) like `WORKSPACE` and `BUILD_TAG`. These are handy in `Jenkinsfile`s for automating stuff like tagging container images, bind-mounting Docker volumes to the Jenkins workspace, etc. 
- The RailsGoat project is a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) of this repo, making it easy to pull upstream changes into the lab environment. In fact, the Brakeman Jenkinsfile does this as part of the build.
- Brakeman returns an exit status of 3 after successfully scanning the RailsGoat code. Jenkins assumes any non-zero exit code from a build step indicates a failed build, so there's extra logic to avoid this problem in the Brakeman Jenkinsfile.

## Under the Hood with Arachni
TODO: update this section for ZAP 

Some of the stuff going on under the hood with the Arachni scan:

- The scan profile (`arachni-railsgoat-quickscan.afp`) used by default uses a small subset of the tests available in Arachni to keep scan times reasonable.
- The scan profile is tuned to RailsGoat: login credentials, a pattern to check if the scan engine is currently authenticated or not, and various other tuning parameters.
- The Arachni `Dockerfile` downloads Arachni over HTTPS and checksums the downloaded package. These are good security practices to validate the integrity of software packages downloaded; don't let yourself get MITM'd!
- The Arachni `docker-compose.yml` file uses `depends_on`, so the RailsGoat container must be up and running before the Arachni scan starts.
- The Arachni `docker-compose.yml` file builds the RailsGoat container using a git submodule (hence the relative build path). The `Jenkinsfile` includes a build step to update this repository, too.

## Under the Hood with Vagrant
TODO: update/delete this section

The `Vagrantfile` is well-commented; some of the handy stuff there:

- Add GPG keys for third-party repos before installing packages from them (Docker, Docker Compose)
- Use of the `docker` group (for the vagrant and jenkins users) to make interacting with the Docker daemon not require `sudo` or `root` privileges
- Port 3000 and 8080 are forwarded from the Vagrant VM to the Vagrant host, and access is limited `127.0.0.1` for security (especially important for RailsGoat, since it's intentionally vulnerable).

## Lab vs. Real-World
TODO: update this section


Of course, things are different in this lab environment vs. in a real-world pipeline. Some key differences:

- In the lab, you might hit performance issues since everything is on a single Vagrant-managed VM, especially for the Arachni scan. This VM handles everything; it runs the Jenkins master, the Jenkins builds, Docker daemon, Docker Compose, etc. In a real pipeline, these components should be split across multiple hosts. A Jenkins master (or cluster), a farm of Jenkins build slaves, a private Docker registry, a dedicated version control server, etc.
- In the lab, containers are built as part of the Jenkins build steps. In a real pipeline, you would likely have separate, ready-made containers available to be pulled from a private registry.
- In the lab, there's not much to worry about in terms of credential management. In a real pipeline, you would likely have centralized LDAP integration for pipeline components, an authorization strategy for the CI server, and you would need to handle passing secrets (SSH keys, API tokens, passwords, whatnot) around the environment.
- In the lab, the source repo is used directly (`file:///vagrant` points to the source repo, thanks to Vagrant's default share). In a real pipeline, a dedicated version control server (or cluster/farm) would be the way to go. This opens all kinds of opportunities for automatically triggering jobs to test security in response to pushes, merges, etc.
- In the lab, tool-generated reports are simply saved with the job. This is a good start; but in a real pipeline with mature security process, you might parse the tool output, filter false positives/already-known issues, perhaps feed the resulting issues in a defect tracking system.
- In the lab, containers run as root to avoid permission problems writing reports to the Jenkins workspace. Best practice is to avoid privileged containers; security impact of and solutions to this vary depending on your environment. It's generally most important to avoid running root-privileged containers in production.

