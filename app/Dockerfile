FROM questhub_backend

ENV APP_HOME /play/app
WORKDIR $APP_HOME

# Ruby needed for erb config generation.
# Ruby included in backend container too, so it's technically not necessary here.
RUN apt-get install -y ruby

# For XML::LibXML, used in tests.
RUN apt-get install -y libxml2-dev

COPY cpanfile $APP_HOME/cpanfile
RUN cpanm --notest --installdeps .

# $APP_HOME will be remounted in development
COPY . $APP_HOME
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 80
CMD /entrypoint.sh
