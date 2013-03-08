#!/bin/sh
CODE=$(cat <<'END'
use play
db.user_settings.update({ "result": { $exists: true } }, { $unset: { "result": 1 } } )
END
)

echo "$CODE" | mongo
