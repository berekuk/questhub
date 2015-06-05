#!/bin/bash
set -euo pipefail

cd /www
export PATH=./node_modules/.bin:$PATH

if [ $QH_DEV = 1 ]; then
    export NODE_ENV=development
    foreman start --procfile Procfile.dev
else
    export NODE_ENV=production
    foreman start --procfile Procfile.prod
fi
