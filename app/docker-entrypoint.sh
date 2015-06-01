#!/bin/bash
set -euo pipefail

cd $APP_HOME
erb ./config.yml.erb >./config.yml
LOG_DIR=/data/dancer
mkdir -p $LOG_DIR

PLACKUP_FLAGS=''
if [ $QH_DEV = 1 ]; then
    PLACKUP_FLAGS=-r
fi

(cd /play/backend && ./generate-backend-config.sh)
plackup --server Starman --port 80 $PLACKUP_FLAGS app.pl >>$LOG_DIR/stdout.log 2>>$LOG_DIR/stderr.log
