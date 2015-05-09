#!/bin/bash
set -euo pipefail

cd $APP_HOME
erb ./config.yml.erb >./config.yml
LOG_DIR=/data/dancer
mkdir -p $LOG_DIR
plackup --server Starman --port 80 bin/app.pl >>$LOG_DIR/stdout.log 2>>$LOG_DIR/stderr.log
