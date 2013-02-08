#!/bin/sh

rm -rf dump
ssh ubuntu@play-perl.org "sh -c 'rm -rf dump && mongodump'"
scp -r ubuntu@play-perl.org:dump .
vagrant ssh -c 'cd /play/app && ./clear_mongo.sh'
vagrant ssh -c 'cd /play && mongorestore'
vagrant ssh -c 'sudo ubic try-restart -f'
