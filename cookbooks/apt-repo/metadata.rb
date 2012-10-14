maintainer       "Sebastian Boehm"
maintainer_email "sebastian@sometimesfood.org"
license          "MIT"
description      "Add repositories to APT sources"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
#version          "0.1"

recipe "apt-repo",            "Add repositories to APT sources"
recipe "apt-repo::grml",      "Add Grml APT repo to APT sources"
recipe "apt-repo::medibuntu", "Add medibuntu APT repo to APT sources"

%w(ubuntu debian).each do |os|
  supports os
end
