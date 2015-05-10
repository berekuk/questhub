#!/bin/bash

set -e

mkdir -p /data/dev

./node_modules/.bin/webpack -wc 2>&1
