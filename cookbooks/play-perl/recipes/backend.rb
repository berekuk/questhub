cpan_module 'Flux::File'
cpan_module 'Flux::Format'
cpan_module 'Log::Any::Adapter'

directory "/data/pumper"
directory "/data/storage"
directory "/data/storage/email"
file "/data/storage/email/log" do
    action :create_if_missing
end

include_recipe "ubic"
ubic_service "sendmail" do
  action [:install, :start]
end

template "/etc/logrotate.d/sendmail-pumper" do
  source "logrotate.conf.erb"
  mode 0644
  variables({
    :log => '/data/pumper/sendmail.log /data/pumper/sendmail.err.log',
    :postrotate => 'ubic reload sendmail',
  })
end
