#!/bin/sh

ssh ubuntu@play-perl.org "sh -c 'rm -rf dump && rm -f backup.tar.gz && mongodump -d play && tar cfvz backup.tar.gz dump'"
scp ubuntu@play-perl.org:backup.tar.gz .
mv backup.tar.gz ~/Dropbox/backup/play-perl/$(date "+%Y-%m-%d").tar.gz
