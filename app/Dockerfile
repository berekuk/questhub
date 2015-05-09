FROM questhub_backend

ENV APP_HOME /play/app

RUN cpanm --notest -i Dancer Starman Dancer::Serializer::JSON Dancer::Session::MongoDB Dancer::Plugin::Auth::Twitter Template

# needed for erb config generation
# it's included in backend container too, so it's technically not necessary here
RUN apt-get install -y ruby

RUN mkdir -p /play

# will be remounted in development
COPY . $APP_HOME

EXPOSE 80

WORKDIR $APP_HOME
CMD ./run.sh
