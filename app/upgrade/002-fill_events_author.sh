#!/bin/sh
CODE=$(cat <<END
use play
db.events.find().snapshot().forEach(function (doc) {
    if (doc.object_type == 'quest') {
        doc.author = doc.object.user;
    }
    else if (doc.object_type == 'comment') {
        doc.author = doc.object.author;
    }
    else if (doc.object_type == 'user') {
        doc.author = doc.object.login;
    }
    db.events.save(doc);
})
END
)

echo "$CODE" | mongo

CODE=$(cat <<END
use play
db.quests.find().snapshot().forEach(function (doc) {
    doc.author = doc.user;
    db.quests.save(doc);
})
END
)

echo "$CODE" | mongo
