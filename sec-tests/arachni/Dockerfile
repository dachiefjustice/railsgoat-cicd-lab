# Purpose: package Arachni for use in Jenkins pipeline

FROM ubuntu:latest

ARG arachni_archive_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.3/arachni-1.6.1.3-0.6.1.1-linux-x86_64.tar.gz
ARG arachni_sha512_url=https://github.com/Arachni/arachni/releases/download/v1.6.1.3/arachni-1.6.1.3-0.6.1.1-linux-x86_64.tar.gz.sha512

ARG chrome_deb_url=https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
ARG chromedriver_pkg_url=https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/115.0.5790.170/linux64/chromedriver-linux64.zip

# Install:
#   - Supporting tools: wget, curl, ca-certificates, unzip
#   - Arachni
#   - Google Chrome
#   - Chromedriver
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
    wget -q -O /tmp/chrome.deb $chrome_deb_url && \
    dpkg --install /tmp/chrome.deb && \
    wget -q -O /tmp/chromedriver.zip $chromedriver_pkg_url && \
    mkdir /tmp/chromedriver-program && \
    unzip /tmp/chromedriver.zip chromedriver-linux64/* -d /tmp/chromedriver-program && \
    mv /tmp/chromedriver-program/chromedriver /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver && \
    rm -rf /tmp/chrome.deb /tmp/chromedriver.zip /tmp/chromedriver-program && \
    addgroup --system --gid 1000 arachni-scan && \
    adduser --system --uid 1000 --group arachni-scan --no-create-home --disabled-password --shell /bin/bash

# Add arachni's bin directory to $PATH
ENV PATH="/opt/arachni/bin:${PATH}"

# Use service account
USER arachni-scan:arachni-scan

# Interactive shell by default
CMD ["/bin/bash"]
