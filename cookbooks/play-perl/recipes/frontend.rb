package 'nginx'

directory '/data' # logs

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
    :dancer_port => 3000,
    :static_root => '/play/www/built-production'
  })
  notifies :restart, "service[nginx]"
end

template "/etc/nginx/sites-enabled/old" do
  source "nginx-site-old.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[nginx]"
end

include_recipe "play-perl::node"
include_recipe "phantomjs"

service "nginx"
