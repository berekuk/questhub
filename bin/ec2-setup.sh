#!/bin/bash
# Based on setup.sh from https://github.com/lynaghk/vagrant-ec2.

# This script uploads everything required for `chef-solo` to run
set -e

if test -z "$1"
then
  echo "I need an IP address or hostname of a machine to provision"
  exit 1
fi

ADDR=$1

USERNAME=ubuntu

# make sure this matches the CHEF_FILE_CACHE_PATH in `ec2-bootstrap.sh`
CHEF_FILE_CACHE_PATH=/tmp/cheftime

# upload everything to the home directory (need to use sudo to copy over to $CHEF_FILE_CACHE_PATH and run chef)
echo "Uploading cookbooks tarball and dna.json"
scp -i $EC2_SSH_PRIVATE_KEY -r cookbooks.tgz dna.json $USERNAME@$ADDR:.

echo "Running chef-solo"

# check to see if the bootstrap script has completed running
eval "ssh -q -t -l \"$USERNAME\" -i \"$EC2_SSH_PRIVATE_KEY\" $USERNAME@$ADDR \"sudo -i which chef-solo > /dev/null \""

if [ "$?" -ne "0" ] ; then
    echo "chef-solo not found on remote machine; it is probably still bootstrapping, give it a minute."
    exit
fi

tar cfz cookbooks.tgz cookbooks

# run chef-solo
ssh -t -l $USERNAME -i $EC2_SSH_PRIVATE_KEY $USERNAME@$ADDR "sudo -i sh -c '\
cp /home/$USERNAME/cookbooks.tgz $CHEF_FILE_CACHE_PATH && \
cp /home/$USERNAME/dna.json $CHEF_FILE_CACHE_PATH && \
chef-solo -c $CHEF_FILE_CACHE_PATH/solo.rb -j $CHEF_FILE_CACHE_PATH/dna.json -r $CHEF_FILE_CACHE_PATH/cookbooks.tgz'"
