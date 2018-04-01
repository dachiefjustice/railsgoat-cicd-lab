# Purpose: package Arachni for use in Jenkins pipeline

# PhantomJS didn't spawn threads properly on Alpine, so Ubuntu instead.
FROM ubuntu:latest

# Install wget and Arachni
# Verify arachni's sha512 checksum
RUN apt-get update && apt-get install --no-install-recommends --yes wget ca-certificates && \
    wget -q -O /tmp/arachni.tar.gz https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    wget -q -O /tmp/arachni.sha512 https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz.sha512 && \
    cd /tmp && \
    echo "`cat arachni.sha512` arachni.tar.gz" | sha512sum -c - && \
    tar xzf /tmp/arachni.tar.gz -C /tmp && \
    mv /tmp/arachni-1.5.1-0.5.12/ /opt/arachni/ && \
    rm /tmp/arachni.tar.gz /tmp/arachni.sha512

# Add arachni's bin directory to PATH
ENV PATH="/opt/arachni/bin:${PATH}"

# Interactive shell by default
CMD ["/bin/bash"]
