FROM alpine:latest

# Install brakeman dependencies, brakeman
RUN apk add --no-cache --update ruby ruby-rdoc ruby-irb && \
    gem install brakeman

# brakeman help by default
CMD ["/usr/bin/brakeman -h"]
