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
cookbook_path \"/play/cookbooks\"
role_path \"/play/roles\"" > $CHEF_FILE_CACHE_PATH/solo.rb

# install chef
for i in $(seq 1 3); do
    apt-get update # apt-get update is failing sometimes
    sleep 1
done
apt-get --no-install-recommends -y install build-essential ruby ruby-dev rubygems libopenssl-ruby git
gem install --no-rdoc --no-ri moneta -v 0.6.0
gem install --no-rdoc --no-ri net-ssh -v 2.2.2
gem install --no-rdoc --no-ri net-ssh-gateway -v 1.1.0
gem install --no-rdoc --no-ri chef -v 10.16.4
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/gems/1.8/bin"' > /etc/environment
