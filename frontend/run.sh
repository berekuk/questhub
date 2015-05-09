#!/bin/sh
set -euo pipefail

erb /frontend-conf/conf/questhub.conf.erb >/etc/nginx/conf.d/questhub.conf
nginx
