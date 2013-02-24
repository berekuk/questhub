#!/bin/sh

CODE=$(cat <<END
use play
db.quests.drop()
db.users.drop()
db.user_settings.drop()
db.sessions.drop()
db.comments.drop()
db.events.drop()
db.users.ensureIndex({ "login": 1, "twitter.login": 1 }, { "unique": 1 })
db.user_settings.ensureIndex({ "user": 1 }, { "unique": 1 })
db.user_settings.ensureIndex({ "email": 1 }, { "unique": 1 })
END
)

(echo 'use play'; echo "$CODE") | mongo
(echo 'use play_test'; echo "$CODE") | mongo
