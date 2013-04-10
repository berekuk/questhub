#!/bin/sh
CODE=$(cat <<'END'
use play
db.quests.ensureIndex({ "user": 1 })
db.quests.ensureIndex({ "team": 1 })
END
)

echo "$CODE" | mongo
