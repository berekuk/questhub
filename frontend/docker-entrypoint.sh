#!/bin/bash
set -euo pipefail

erb /opt/main.conf.erb >/etc/nginx/conf.d/main.conf
nginx
