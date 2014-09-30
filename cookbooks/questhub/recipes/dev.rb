# auto_reload for development
cpan_module 'Module::Refresh'

cpan_module 'Test::Deep'
cpan_module 'Test::Class'
cpan_module 'Import::Into'
cpan_module 'Carp::Always'
cpan_module 'Capture::Tiny'

# validate atom in tests
package 'libxml2-dev'
cpan_module 'XML::LibXML'

directory "/data/dancer-dev"
ubic_service "dancer-dev" do
  action [:install, :start]
end

template "/etc/nginx/conf.d/questhub-dev.conf" do
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

# for running jasmine tests from CLI
include_recipe "phantomjs"

# used by build_static.pl
cpan_module "IPC::System::Simple"

gem_package 'sass' do
  version '3.4.5'
end
gem_package 'rb-inotify' do
  version '0.9'
end
ubic_service "sass" do
  action [:install, :start]
end

include_recipe "npm"
npm_package "coffee-script"
ubic_service "coffee" do
  action [:install, :start]
end
ubic_service "coffee-test" do
  action [:install, :start]
end

package 'sqlite3'
package 'libsqlite3-dev'
package 'g++'
gem_package 'mailcatcher'
ubic_service "mailcatcher" do
  action [:install, :start]
end
