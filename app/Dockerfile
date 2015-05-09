FROM questhub_backend

ENV APP_HOME /play/app
WORKDIR $APP_HOME

RUN cpanm --notest --installdeps .

# needed for erb config generation
# it's included in backend container too, so it's technically not necessary here
RUN apt-get install -y ruby

# will be remounted in development
COPY . $APP_HOME
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 80

CMD /entrypoint.sh
