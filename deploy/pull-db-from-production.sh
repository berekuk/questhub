#!/bin/sh

rm -rf dump
ssh ubuntu@play-perl.org "sh -c 'rm -rf dump && mongodump -d play'"
scp -r ubuntu@play-perl.org:dump .
vagrant ssh -c 'cd /play/app && ./clear_mongo.sh'
vagrant ssh -c 'cd /play && mongorestore'

# to avoid accidentally sending emails to users while debugging
vagrant ssh -c '(echo '\''use play'\''; echo '\''db.users.update({}, {"$unset": { "settings" : 1 } }, false, true)'\'') | mongo'

vagrant ssh -c 'sudo ubic try-restart -f'
