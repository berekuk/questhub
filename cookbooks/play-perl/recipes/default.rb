require_recipe "mongodb"
require_recipe "perl"

package 'vim'
package 'git'
package 'screen'
package 'make'
package 'perl-doc'

cpan_module 'Dancer'
cpan_module 'YAML'
cpan_module 'MongoDB'
cpan_module 'JSON'
cpan_module 'Params::Validate'
cpan_module 'Moo'
cpan_module 'Test::Deep'

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

template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

# nginx
directory '/web' # logs

package 'nginx'

file '/etc/nginx/sites-enabled/default' do
    action :delete
end

template "/etc/nginx/sites-enabled/play-perl.org" do
  source "nginx-site.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

bash "restart nginx" do
  code <<-EOH
/etc/init.d/nginx restart
EOH
end
