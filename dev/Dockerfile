FROM ubuntu:14.04

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get update && apt-get install -y nodejs

RUN apt-get update && apt-get install -y vim git
RUN cd /root && git clone git://github.com/berekuk/etc && ./etc/script/install_dotfiles
RUN echo 'export PATH=$PATH:./node_modules/.bin' >$HOME/etc/bash/local

CMD /bin/sh -c "while true; do true; sleep 1; done"
