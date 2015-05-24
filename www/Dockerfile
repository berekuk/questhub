# This container is for development only.
# It's capable of rebuilding css and js code on-the-fly.
# (You may need to use 'dev' container to edit files if you're on OSX and use boot2docker, due to inotify issues.)
FROM ubuntu:14.04

ENV APP_HOME /www

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get update && apt-get install -y nodejs

WORKDIR $APP_HOME

COPY package.json $APP_HOME/package.json
RUN npm install

COPY . $APP_HOME
COPY docker-entrypoint.sh /entrypoint.sh

EXPOSE 80
CMD /entrypoint.sh
