#!/bin/sh
CODE=$(cat <<'END'
use play
db.quests.ensureIndex({ "tags": 1 })

db.quests.find({ "type": { "$exists": 1 }}).forEach(function(doc) { db.quests.update({_id: doc._id}, {$set: {"tags": [doc.type]}}); })
END
)

echo "$CODE" | mongo
