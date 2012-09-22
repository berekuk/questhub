require_recipe "mongodb"
require_recipe "perl"

package 'vim'
package 'git'
package 'screen'
package 'make'
package 'perl-doc'

cpan_module 'Dancer'
cpan_module 'MongoDB'

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
