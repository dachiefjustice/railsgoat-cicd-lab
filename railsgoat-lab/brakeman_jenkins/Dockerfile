FROM alpine:latest

# Install git, brakeman dependencies, brakeman
RUN apk add --no-cache --update ruby ruby-rdoc ruby-irb git && \
    gem install brakeman

# Demonstrate no-root pattern (thoug
RUN addgroup -g 1000 -S alpine && \
    adduser -u 1000 -S alpine -G alpine -s /bin/sh
USER alpine:alpine
WORKDIR /home/alpine

# Clone railsgoat code in-container for lab ease-of-use
# In typical pipeline, use CI server to clone source and bind-mount in container
RUN git clone https://github.com/OWASP/railsgoat.git railsgoat

# Set up a volume for brakeman report
RUN mkdir /home/alpine/brakeman_vol
VOLUME /home/alpine/brakeman_vol

# Needs to be root for writing report to Jenkins workspace
USER root
WORKDIR /home/alpine/railsgoat

# Run brakeman, output report to the volume
# Container scans by default for lab ease-of-use
CMD ["brakeman", "-a", "-f", "html", "-o", "/home/alpine/brakeman_vol/railsgoat_brakeman_report.html"]
