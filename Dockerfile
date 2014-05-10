# vim: ft=conf
#
FROM ubuntu:12.04
MAINTAINER Vyacheslav Matyukhin <me@berekuk.ru>

ENV DEBIAN_FRONTEND noninteractive

# mongodb
RUN apt-get update &&\
    apt-get install -y python-software-properties &&\
    apt-add-repository 'deb     http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' &&\
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 &&\
    apt-get update &&\
    apt-get install -y mongodb
ADD cookbooks/questhub/templates/default/mongodb.conf.erb /etc/mongodb.conf

# perl and modules
RUN apt-get install -y perl wget &&\
    wget https://raw.github.com/miyagawa/cpanminus/1.7001/cpanm -O /usr/local/bin/cpanm &&\
    chmod +x /usr/local/bin/cpanm

# libssl-dev is needed by Email::Sender::Simple to send Amazon SES emails
# Email::MIME is for multipart emails
RUN apt-get install -y libssl-dev sendmail make gcc &&\
    cpanm -n Flux::File Flux::Format::JSON Log::Any::Adapter MooX::Options Package::Variant Authen::SASL Net::SMTP::SSL Email::Sender::Transport::SMTP::TLS Email::MIME
RUN mkdir -p /data/pumper /data/storage /data/images/pic # FIXME - volumes
RUN for dir in email events upic; do mkdir -p /data/storage/$dir && touch /data/storage/$dir/log; done

# nginx
RUN apt-add-repository 'deb     http://nginx.org/packages/ubuntu/ precise nginx' &&\
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ABF5BD827BD9BF62 &&\
    apt-get update &&\
    apt-get install -y nginx=1.6.0-1~precise &&\
    rm /etc/nginx/conf.d/default.conf

ADD cookbooks/questhub/templates/default/nginx-site-old.conf.erb /etc/nginx/conf.d/old.conf

# TODO - generate main config
# ADD cookbooks/questhub/templates/default/nginx-site.conf.erb ...

# supervisor
RUN apt-get install -y supervisor
ADD conf/supervisor.conf /etc/supervisor/conf.d/
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

ENTRYPOINT while true; do sleep 1; done
