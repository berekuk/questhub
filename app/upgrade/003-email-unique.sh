#!/bin/sh
CODE=$(cat <<END
use play
db.user_settings.ensureIndex({ "email": 1 }, { "unique": 1 })
END
)

echo "$CODE" | mongo
