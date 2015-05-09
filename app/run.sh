#!/bin/bash

set -e

./generate-config.sh
LOG_DIR=/data/dancer
mkdir -p $LOG_DIR
plackup --server Starman --port $QH_APP_PORT bin/app.pl >>$LOG_DIR/stdout.log 2>>$LOG_DIR/stderr.log
