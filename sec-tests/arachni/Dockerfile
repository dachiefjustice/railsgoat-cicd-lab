# Purpose: package Arachni for use in Jenkins pipeline

FROM ubuntu:latest

ARG arachni_archive_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.3/arachni-1.6.1.3-0.6.1.1-linux-x86_64.tar.gz
ARG arachni_sha512_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.3/arachni-1.6.1.3-0.6.1.1-linux-x86_64.tar.gz.sha512

# Install wget and Arachni
# Verify arachni's sha512 checksum
RUN apt-get update && apt-get install --no-install-recommends --yes wget ca-certificates && \
    wget -q -O /tmp/arachni.tar.gz $arachni_archive_url && \
    wget -q -O /tmp/arachni.sha512 $arachni_sha512_url && \
    cd /tmp && \
    echo "`cat arachni.sha512` arachni.tar.gz" | sha512sum -c - && \
    mkdir /tmp/arachni-program && \
    tar -xzf /tmp/arachni.tar.gz --strip-components=1 -C /tmp/arachni-program && \
    mv /tmp/arachni-program/ /opt/arachni/ && \
    rm /tmp/arachni.tar.gz /tmp/arachni.sha512

# Add arachni's bin directory to $PATH
ENV PATH="/opt/arachni/bin:${PATH}"

# Interactive shell by default
CMD ["/bin/bash"]
