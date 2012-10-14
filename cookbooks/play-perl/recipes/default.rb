include_recipe "mongodb"
include_recipe "perl"

# for development
package 'vim'
package 'git'
package 'screen'
package 'perl-doc'

package 'make' # for compiling MongoDB

cpan_module 'Dancer'
cpan_module 'YAML'
cpan_module 'MongoDB'
cpan_module 'JSON'
cpan_module 'Params::Validate'
cpan_module 'Moo'
cpan_module 'Test::Deep'
cpan_module 'Import::Into'
cpan_module 'Carp::Always'
cpan_module 'Starman'

# auto_reload for development
cpan_module 'Module::Refresh'
cpan_module 'Clone'

cpan_module 'Dancer::Serializer::JSON'
cpan_module 'Dancer::Session::MongoDB'
cpan_module 'Dancer::Plugin::Auth::Twitter'

include_recipe "mongodb::default"

template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

directory '/web' # logs

# dancer services
include_recipe "ubic"
cpan_module 'Ubic::Service::Plack'
directory "/web/dancer"
ubic_service "dancer" do
  action [:install, :start]
end
directory "/web/dancer-dev"
ubic_service "dancer-dev" do
  action [:install, :start]
end

# nginx
package 'nginx'

file '/etc/nginx/sites-enabled/default' do
    action :delete
end

template "/etc/nginx/sites-enabled/play-perl.org" do
  source "nginx-site.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :port => 80,
    :dancer_port => 3000
  })
  notifies :restart, "service[nginx]"
end

template "/etc/nginx/sites-enabled/play-perl-dev.org" do
  source "nginx-site.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :port => 81,
    :dancer_port => 3001
  })
  notifies :restart, "service[nginx]"
end

service "nginx"
