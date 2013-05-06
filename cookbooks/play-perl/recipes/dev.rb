# auto_reload for development
cpan_module 'Module::Refresh'

cpan_module 'Test::Deep'
cpan_module 'Test::Class'
cpan_module 'Import::Into'
cpan_module 'Carp::Always'

# validate atom in tests
package 'libxml2-dev'
cpan_module 'XML::LibXML'

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
    :static_root => '/play/www',
    :dev => true
  })
  notifies :restart, "service[nginx]"
end

include_recipe "play-perl::node"
include_recipe "phantomjs"

# used by build_static.pl
cpan_module "IPC::System::Simple"

gem_package 'sass'
gem_package 'rb-inotify' do
  version '0.8.8'
end
ubic_service "sass" do
  action [:install, :start]
end
