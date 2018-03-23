FROM alpine:latest

# Install git, brakeman dependencies, brakeman
RUN apk add --no-cache --update ruby ruby-rdoc ruby-irb git && \
    gem install brakeman

# No need for root
RUN addgroup -g 1000 -S alpine && \
    adduser -u 1000 -S alpine -G alpine -s /bin/sh
USER alpine:alpine
WORKDIR /home/alpine

# Get the railsgoat code
RUN git clone https://github.com/OWASP/railsgoat.git railsgoat

# Set up a volume for brakeman report
RUN mkdir /home/alpine/brakeman_vol
VOLUME /home/alpine/brakeman_vol

# Interactive shell by default
# CMD ["/bin/sh"]

# Run brakeman, output report to the volume
USER root
WORKDIR /home/alpine/railsgoat
CMD ["brakeman", "-a", "-f", "html", "-o", "/home/alpine/brakeman_vol/railsgoat_brakeman_report.html"]
