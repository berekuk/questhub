#!/bin/bash
set -euo pipefail

cd $APP_HOME
erb ./config.yml.erb >./config.yml
LOG_DIR=/data/dancer
mkdir -p $LOG_DIR

PLACKUP_FLAGS=''
if [ -n $QH_DEV ]; then
    PLACKUP_FLAGS=-r
    export DANCER_ENVIRONMENT=production
else
    export DANCER_ENVIRONMENT=development
fi

plackup --server Starman --port 80 $PLACKUP_FLAGS bin/app.pl >>$LOG_DIR/stdout.log 2>>$LOG_DIR/stderr.log
