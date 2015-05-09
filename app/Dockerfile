FROM questhub_backend

ENV APP_HOME /play/app

RUN cpanm --notest -i Dancer Starman Dancer::Serializer::JSON Dancer::Session::MongoDB Dancer::Plugin::Auth::Twitter Template
RUN apt-get install -y ruby

RUN mkdir -p /play

# will be remounted in development
COPY . $APP_HOME

# expect to be mounted: /config
# expect to be mounted: /play/backend

WORKDIR $APP_HOME
CMD ./run.sh
