# This container is for development only.
# It's capable of rebuilding css and js code on-the-fly.
# (You may need to use 'dev' container to edit files if you're on OSX and use boot2docker, due to inotify issues.)
FROM node:0.12

ENV APP_HOME /www
WORKDIR $APP_HOME

COPY . $APP_HOME
RUN npm install

COPY docker-entrypoint.sh /entrypoint.sh
CMD /entrypoint.sh
