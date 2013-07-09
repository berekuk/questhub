#!/bin/sh

CODE=$(cat <<END
use play
db.quests.drop()
db.users.drop()
db.sessions.drop()
db.comments.drop()
db.events.drop()
db.library.drop()
END
)

(echo 'use play'; echo "$CODE") | mongo
(echo 'use play_test'; echo "$CODE") | mongo

perl -I/play/backend/lib -e 'use Play::DB qw(db); db->ensure_indices'
