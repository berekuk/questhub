#!/bin/bash
set -euo pipefail

CONF_DIR=/etc/nginx/conf.d
CONF_FILE=$CONF_DIR/main.conf

erb ${CONF_FILE}.erb >$CONF_FILE
nginx
