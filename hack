#!/bin/sh

echo "Entering the docker container for editing the mounted code volumes."
echo "This container includes berekuk's familiar environment and dotfiles. You might want to edit dev/Dockerfile if you prefer something else."
exec docker exec -it questhub_dev_1 bash
