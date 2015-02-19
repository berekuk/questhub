name             "ubic"
maintainer       "Vyacheslav Matyukhin"
maintainer_email "me@berekuk.ru"
license          "GPL"
description      "Installs/Configures ubic"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"

depends "apt"

supports "ubuntu"
supports "debian", ">= 4.0"
