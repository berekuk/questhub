# auto_reload for development
cpan_module 'Module::Refresh'

cpan_module 'Test::Deep'
cpan_module 'Test::Class'
cpan_module 'Import::Into'
cpan_module 'Carp::Always'

directory "/data/dancer-dev"
ubic_service "dancer-dev" do
  action [:install, :start]
end

template "/etc/nginx/sites-enabled/play-perl-dev.org" do
  source "nginx-site.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :port => 81,
    :dancer_port => 3001,
    :static_root => '/play/www'
  })
  notifies :restart, "service[nginx]"
end

ppa "chris-lea/node.js"
package "nodejs"

ppa "antono/phantomjs"
package "phantomjs"
