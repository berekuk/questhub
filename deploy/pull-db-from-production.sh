#!/bin/sh

#vagrant ssh -c 'cd /play/app && ./clear_mongo.sh'

rm -rf dump
mkdir dump

ssh ubuntu@play-perl.org "sh -c 'rm -rf dump && mongodump -d play'"
scp -r ubuntu@play-perl.org:dump/play ./dump/play-perl

ssh ubuntu@questhub.io "sh -c 'rm -rf dump && mongodump -d play'"
scp -r ubuntu@questhub.io:dump/play ./dump/play-qh

vagrant ssh -c 'cd /play && mongorestore'
vagrant ssh -c 'cd /play && ./deploy/merge-realms.pl'

## to avoid accidentally sending emails to users while debugging
vagrant ssh -c '(echo '\''use play'\''; echo '\''db.users.update({}, {"$unset": { "settings" : 1 } }, false, true)'\'') | mongo'
