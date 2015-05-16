FROM ubuntu:14.04

ENV APP_HOME /play/backend
WORKDIR $APP_HOME

# libssl-dev is needed by Email::Sender::Simple to send Amazon SES emails
# ruby is needed for erb config generation
RUN apt-get update && apt-get install -y libssl-dev sendmail curl supervisor make perl libgd2-xpm-dev ruby

RUN curl -L https://cpanmin.us | perl - --sudo App::cpanminus

COPY cpanfile $APP_HOME/cpanfile
RUN cpanm --notest --installdeps .

# will be remounted in development
COPY . $APP_HOME

COPY docker-entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
