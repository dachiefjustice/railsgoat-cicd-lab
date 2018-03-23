FROM alpine:latest

RUN apk add --no-cache --update wget bash ca-certificates

# arachni needs glibc, Alpine is based on musl, install third-party glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk && \
    apk add glibc-2.27-r0.apk

# No need for root
RUN addgroup -g 1000 -S alpine && \
    adduser -u 1000 -S alpine -G alpine -s /bin/sh
USER alpine:alpine
WORKDIR /home/alpine

# Download + extract arachni
RUN wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    tar xzf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz && \
    mv arachni-1.5.1-0.5.12 arachni && \
    mkdir /home/alpine/arachni_vol

# Set up a volume (for saving reports)
VOLUME /home/alpine/arachni_vol

# Interactive shell by default
CMD ["/bin/bash"]
