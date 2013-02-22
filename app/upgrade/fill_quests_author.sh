#!/bin/sh
CODE=$(cat <<END
use play
db.quests.find().snapshot().forEach(function (doc) {
    doc.author = doc.user;
    db.quests.save(doc);
})
END
)

echo "$CODE" | mongo
