#!/bin/bash
set -euo pipefail

cd $APP_HOME

mkdir -p /data/{pumper,storage/{email,events,upic},images/pic}
touch /data/storage/{email,events,upic}/log

./generate-backend-config.sh
/usr/bin/supervisord -c ./supervisord.conf
