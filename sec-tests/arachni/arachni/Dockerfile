# Purpose: package Arachni for use in Jenkins pipeline

# Tested on alpine, PhantomJS didn't spawn properl, so using Ubuntu.
# Possibly musl libc vs glibc related.
FROM ubuntu:latest

# Use /root for Arachni installation
WORKDIR /root

# Install wget and Arachni
# arachni will be in /root/arachni
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    tar xzf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    mv arachni-1.5.1-0.5.12 arachni && \
    mkdir /arachni_vol

# /arachni_vol for providing profiles and saving reports
VOLUME /arachni_vol

# Interactive shell by default
CMD ["/bin/bash"]
