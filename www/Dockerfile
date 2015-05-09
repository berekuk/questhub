FROM node:0.12

ENV APP_HOME /www

RUN apt-get update && apt-get install -y ruby ruby-dev supervisor
RUN gem install sass rb-inotify
RUN npm install -g coffee-script

WORKDIR $APP_HOME
CMD ./run.sh
