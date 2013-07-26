#!/bin/sh
CODE=$(cat <<END
use play
db.comments.find().snapshot().forEach(function (doc) {
    doc.eid = doc.quest_id
    doc.entity = 'quest'
    db.comments.save(doc);
})
END
)

echo "$CODE" | mongo
