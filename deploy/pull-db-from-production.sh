#!/bin/sh

vagrant ssh -c 'cd /play/app && ./clear_mongo.sh'

rm -rf dump
mkdir dump

ssh ubuntu@questhub.io "sh -c 'rm -rf dump && mongodump -d play'"
scp -r ubuntu@questhub.io:dump/play ./dump/play

vagrant ssh -c 'cd /play && mongorestore'

## to avoid accidentally sending emails to users while debugging
vagrant ssh -c '(echo '\''use play'\''; echo '\''db.users.update({}, {"$unset": { "settings" : 1 } }, false, true)'\'') | mongo'
