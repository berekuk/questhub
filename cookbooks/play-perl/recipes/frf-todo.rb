include_recipe "play-perl::backend"

execute "start events2frf" do
  command "ubic start pumper.events2frf"
end

template "/etc/logrotate.d/events2frf-pumper" do
  source "logrotate.conf.erb"
  mode 0644
  variables({
    :log => '/data/pumper/events2frf.log /data/pumper/events2frf.err.log',
    :postrotate => 'ubic reload events2frf',
  })
end

