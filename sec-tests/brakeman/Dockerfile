FROM alpine:latest

# Install brakeman dependencies, brakeman
RUN apk add --no-cache --update ruby ruby-rdoc ruby-irb && \
    gem install brakeman

# Interactive shell by default
CMD ["/bin/sh"]
