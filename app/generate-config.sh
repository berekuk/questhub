#!/bin/sh

set -e
export HOSTPORT=localhost:3000
export SERVICE_NAME=Questhub.io
export TWITTER_CONSUMER_KEY=IRUAzmA5AjwBTrPQWrCzIQ
export TWITTER_CONSUMER_SECRET=Cj4hB54BLMYeoG9eEX4fd5gexg02nQLIRJ2S3f0nAH4

erb /play/app/config.yml.erb >>/play/app/config.yml
