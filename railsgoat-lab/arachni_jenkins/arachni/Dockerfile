FROM ubuntu:latest
WORKDIR /root
RUN apt-get update && apt-get install -y wget && \
    wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    tar xzf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    mv arachni-1.5.1-0.5.12 arachni && \
    mkdir /arachni_vol
VOLUME /arachni_vol
CMD ["/bin/bash"]
