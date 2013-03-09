maintainer       "Vyacheslav Matyukhin"
maintainer_email "me@berekuk.ru"

recipe "play-perl",            "Configure play-perl website"

depends "perl"
depends "ubic"

%w(ubuntu).each do |os|
  supports os
end
