#!/bin/bash

set -e

if [ $QH_DEV = 0 ]; then
    ./node_modules/.bin/webpack --optimize-minimize --devtool source-map
else
    ./node_modules/.bin/webpack -wc 2>&1
fi
