FROM ubuntu:14.04

RUN apt-get update && apt-get install -y vim git
RUN cd /root && git clone git://github.com/berekuk/etc && ./etc/script/install_dotfiles

CMD /bin/sh -c "while true; do echo hello world; sleep 1; done"
