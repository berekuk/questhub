#!/bin/sh

(echo 'use play'; echo 'db.quests.drop()'; echo 'db.users.drop()') | mongo
(echo 'use play_perl'; echo 'db.quests.drop()'; echo 'db.users.drop()') | mongo
(echo 'use play_test'; echo 'db.quests.drop()'; echo 'db.users.drop()') | mongo
