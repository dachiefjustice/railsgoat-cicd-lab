FROM ubuntu:latest
WORKDIR /root
RUN apt-get update && apt-get install -y wget
RUN cd /root && wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
RUN tar xzf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && mv arachni-1.5.1-0.5.12 arachni
RUN mkdir /arachni_vol
VOLUME /arachni_vol
CMD ["/root/arachni/bin/arachni", "http://railsgoat-web:3000", "--profile-load-filepath", "/arachni_vol/arachni-railsgoat-profile.afp", "--report-save-path=/arachni_vol/railsgoat-arachni.afr"]
