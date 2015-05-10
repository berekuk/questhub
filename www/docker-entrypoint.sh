#!/bin/bash

set -e

mkdir -p /data/dev
/usr/bin/supervisord -c $APP_HOME/supervisord.conf
