#!/bin/bash
# Based on bootstrap.sh from https://github.com/lynaghk/vagrant-ec2.

# This script installs ruby, rubygems, and chef.
# Run this script on a new EC2 instance as the user-data script, which is run by `root` on machine startup.
set -e -x

# logging, thanks to http://alestic.com/2010/12/ec2-user-data-output
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# config
export DEBIAN_FRONTEND=noninteractive
export CHEF_COOKBOOK_PATH=/tmp/cheftime/cookbooks
export CHEF_FILE_CACHE_PATH=/tmp/cheftime

mkdir -p $CHEF_FILE_CACHE_PATH
mkdir -p $CHEF_COOKBOOK_PATH

# chef-solo config
echo "file_cache_path \"$CHEF_FILE_CACHE_PATH\"
cookbook_path \"$CHEF_COOKBOOK_PATH\"
role_path []" > $CHEF_FILE_CACHE_PATH/solo.rb

# install chef
apt-get update
apt-get --no-install-recommends -y install build-essential ruby ruby-dev rubygems libopenssl-ruby
gem install --no-rdoc --no-ri chef
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin"' > /etc/environment
