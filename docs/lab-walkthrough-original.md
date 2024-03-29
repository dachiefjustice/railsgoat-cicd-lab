## Lab Walkthrough
### Initial Setup
1. On a host meeting the prereqs, clone this repo: `git clone https://github.com/dachiefjustice/railsgoat-cicd-lab.git`
2. `cd` into the cloned repo, `vagrant up`. Good time to grab a coffee, lots of downloading and installing is about to happen.
3. Once the Vagrant VM is done setting up, `vagrant ssh` in. You'll know it's done once the previous `vagrant up` returns to a prompt in your shell.
![vagrant ssh](screenshots/02_vagrantssh.png)
4. Time to set up Jenkins, which is running on port 8080 in the VM and is exposed from the VM to your Vagrant host. Open http://localhost:8080 in a browser on your Vagrant host.
5. Jenkins sets a random initial password, you'll need this to log in. In the VM `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`, copy/paste into the browser, and move to the next screen.
![jenkins initial pw](screenshots/04_jenkinsInitialLogin.png)
6. Install the suggested plugins, the lab makes use of some of them (notably Pipeline and Git).
![jenkins default plugins](screenshots/05_installSuggestedPlugins.png)
![jenkins installing plugins](screenshots/06_suggestedPluginsInstalling.png)
7. Set up an administrative user, using whatever credentials/info you like.
![jenkins setup admin user](screenshots/07_setUpAdminUser.png)
8. After setting up a Jenkins admin user, click the "Start using Jenkins" button on the next screen.

### Static Analysis with Brakeman
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

### Dynamic Analysis with Arachni
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
Some of the stuff going on under the hood with the Brakeman test:

- Why use Alpine Linux for the Brakeman container? It's lightweight, minimizes attack surface, and results in smaller, faster, and cleaner Docker containers than more full-featured Linux distributions.
- The `checkout scm` step in the `Jenkinsfile` copies the source repo configured in Jenkins jobs into the workspace (for later use by the Brakeman container).
- Jenkins sets [a bunch of environment variables](https://wiki.jenkins.io/display/JENKINS/Building+a+software+project) like `WORKSPACE` and `BUILD_TAG`. These are handy in `Jenkinsfile`s for automating stuff like tagging container images, bind-mounting Docker volumes to the Jenkins workspace, etc. 
- The RailsGoat project is a [submodule](https://git-scm.com/book/en/v2/Git-Tools-Submodules) of this repo, making it easy to pull upstream changes into the lab environment. In fact, the Brakeman Jenkinsfile does this as part of the build.
- Brakeman returns an exit status of 3 after successfully scanning the RailsGoat code. Jenkins assumes any non-zero exit code from a build step indicates a failed build, so there's extra logic to avoid this problem in the Brakeman Jenkinsfile.

## Under the Hood with Arachni
Some of the stuff going on under the hood with the Arachni scan:

- The scan profile (`arachni-railsgoat-quickscan.afp`) used by default uses a small subset of the tests available in Arachni to keep scan times reasonable.
- The scan profile is tuned to RailsGoat: login credentials, a pattern to check if the scan engine is currently authenticated or not, and various other tuning parameters.
- The Arachni `Dockerfile` downloads Arachni over HTTPS and checksums the downloaded package. These are good security practices to validate the integrity of software packages downloaded; don't let yourself get MITM'd!
- The Arachni `docker-compose.yml` file uses `depends_on`, so the RailsGoat container must be up and running before the Arachni scan starts.
- The Arachni `docker-compose.yml` file builds the RailsGoat container using a git submodule (hence the relative build path). The `Jenkinsfile` includes a build step to update this repository, too.

## Under the Hood with Vagrant
The `Vagrantfile` is well-commented; some of the handy stuff there:

- Add GPG keys for third-party repos before installing packages from them (Docker, Docker Compose)
- Use of the `docker` group (for the vagrant and jenkins users) to make interacting with the Docker daemon not require `sudo` or `root` privileges
- Port 3000 and 8080 are forwarded from the Vagrant VM to the Vagrant host, and access is limited `127.0.0.1` for security (especially important for RailsGoat, since it's intentionally vulnerable).

## Lab vs. Real-World
Of course, things are different in this lab environment vs. in a real-world pipeline. Some key differences:

- In the lab, you might hit performance issues since everything is on a single Vagrant-managed VM, especially for the Arachni scan. This VM handles everything; it runs the Jenkins master, the Jenkins builds, Docker daemon, Docker Compose, etc. In a real pipeline, these components should be split across multiple hosts. A Jenkins master (or cluster), a farm of Jenkins build slaves, a private Docker registry, a dedicated version control server, etc.
- In the lab, containers are built as part of the Jenkins build steps. In a real pipeline, you would likely have separate, ready-made containers available to be pulled from a private registry.
- In the lab, there's not much to worry about in terms of credential management. In a real pipeline, you would likely have centralized LDAP integration for pipeline components, an authorization strategy for the CI server, and you would need to handle passing secrets (SSH keys, API tokens, passwords, whatnot) around the environment.
- In the lab, the source repo is used directly (`file:///vagrant` points to the source repo, thanks to Vagrant's default share). In a real pipeline, a dedicated version control server (or cluster/farm) would be the way to go. This opens all kinds of opportunities for automatically triggering jobs to test security in response to pushes, merges, etc.
- In the lab, tool-generated reports are simply saved with the job. This is a good start; but in a real pipeline with mature security process, you might parse the tool output, filter false positives/already-known issues, perhaps feed the resulting issues in a defect tracking system.
- In the lab, containers run as root to avoid permission problems writing reports to the Jenkins workspace. Best practice is to avoid privileged containers; security impact of and solutions to this vary depending on your environment. It's generally most important to avoid running root-privileged containers in production.

## Notes & Tips
- There are lots of moving parts (automatic download/installation from third-party sources) in this lab. Not much version pinning, it's built to stay up-to-date (with the tradeoff that things might break unexpectedly).
- I've sprinkled explanatory comments throughout the lab's source files.
- If you hit performance issues or timeouts with the Arachni scan, try either re-running the Jenkins job (I've seen it work after failing the first time with no changes) or increasing the memory allocated to the VM in the `Vagrantfile`:
```
config.vm.provider "virtualbox" do |vb|
  vb.memory = "4096"
end
```
