#!/bin/bash
set -euo pipefail

if [ $QH_DEV = 1 ]; then
    export NODE_ENV=development
else
    export NODE_ENV=production
fi
node index.js
