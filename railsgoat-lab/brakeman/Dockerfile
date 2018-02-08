FROM ubuntu:latest
WORKDIR /root
RUN apt-get update && apt-get install -y ruby git && gem install brakeman
RUN git clone https://github.com/OWASP/railsgoat.git && cd railsgoat
WORKDIR /root/railsgoat
RUN mkdir /brakeman_vol
VOLUME /brakeman_vol
CMD ["brakeman", "-a", "-f", "html", "-o", "/brakeman_vol/railsgoat_brakeman_report.html"]
