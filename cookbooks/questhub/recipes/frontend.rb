apt_repository 'nginx' do
    uri 'http://nginx.org/packages/ubuntu/'
    distribution 'precise'
    components ['nginx']
    keyserver "keyserver.ubuntu.com"
    key "ABF5BD827BD9BF62"
    action :add
end
package 'nginx-common' do
    action :remove
end
package 'nginx-full' do
    action :remove
end
package 'nginx' do
    version "1.6.0-1~precise"
end

directory '/data' # logs

file '/etc/nginx/conf.d/default.conf' do
  action :delete
end

template "/etc/nginx/conf.d/questhub.conf" do
  source "nginx-site.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
    :port => 80,
    :dancer_port => 3000,
    :static_root => '/play/www-build',
    :ssl => node['play_perl']['ssl'],
    :host => node['play_perl']['hostport']
  })
  notifies :restart, "service[nginx]"
end

template "/etc/nginx/conf.d/old.conf" do
  source "nginx-site-old.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[nginx]"
end

include_recipe "phantomjs" # for generating static files - not used yet

service "nginx"
