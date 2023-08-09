# Purpose: package Arachni for use in Jenkins pipeline

FROM ubuntu:latest

ARG arachni_archive_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.1/arachni-1.6.1.1-0.6.1.1-linux-x86_64.tar.gz
ARG arachni_sha512_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.1/arachni-1.6.1.1-0.6.1.1-linux-x86_64.tar.gz.sha512

# Install:
#   - Supporting tools: wget, curl, ca-certificates, unzip
#   - Arachni
# Clean up temp files
# Add arachni-scan service account and group
RUN apt-get update && \
    apt-get install --no-install-recommends --yes wget curl ca-certificates unzip && \
    wget -q -O /tmp/arachni.tar.gz $arachni_archive_url && \
    wget -q -O /tmp/arachni.sha512 $arachni_sha512_url && \
    cd /tmp && \
    echo "`cat arachni.sha512` arachni.tar.gz" | sha512sum -c - && \
    mkdir /tmp/arachni-program && \
    tar -xzf /tmp/arachni.tar.gz --strip-components=1 -C /tmp/arachni-program && \
    mv /tmp/arachni-program/ /opt/arachni/ && \
    rm /tmp/arachni.tar.gz /tmp/arachni.sha512  && \
    addgroup --system --gid 1000 arachni-scan && \
    adduser --system --uid 1000 --group arachni-scan --no-create-home --disabled-password --shell /bin/bash

# Add arachni's bin directory to $PATH
ENV PATH="/opt/arachni/bin:${PATH}"

# Use service account
USER arachni-scan:arachni-scan

# Interactive shell by default
CMD ["/bin/bash"]
