FROM ubuntu:latest
EXPOSE 9292
WORKDIR /root
RUN apt-get update && apt-get install -y wget
RUN cd /root && wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
RUN tar xzf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && mv arachni-1.5.1-0.5.12 arachni
CMD [ "/bin/bash", "/root/arachni/bin/arachni_web", "-o", "0.0.0.0"]
