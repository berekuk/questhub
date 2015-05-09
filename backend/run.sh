#!/bin/bash

set -e

mkdir -p /data/{pumper,storage/{email,events,upic},images/pic}
touch /data/storage/{email,events,upic}/log

$APP_HOME/generate-backend-config.sh
/usr/bin/supervisord -c $APP_HOME/supervisord.conf
