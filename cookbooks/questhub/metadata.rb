name             "questhub"
maintainer       "Vyacheslav Matyukhin"
maintainer_email "me@berekuk.ru"

recipe "questhub",            "Configure questhub website"

depends "perl"
depends "ubic"
depends "nodejs"

%w(ubuntu).each do |os|
  supports os
end
