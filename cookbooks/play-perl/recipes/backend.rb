cpan_module 'Flux::File'
cpan_module 'Flux::Format::JSON'
cpan_module 'Log::Any::Adapter'
cpan_module 'MooX::Options'
cpan_module 'Package::Variant'

directory "/data/pumper"
directory "/data/storage"

# FIXME - copypaste!
directory "/data/storage/email"
file "/data/storage/email/log" do
    action :create_if_missing
end

directory "/data/storage/comments"
file "/data/storage/comments/log" do
    action :create_if_missing
end

include_recipe "ubic"
ubic_service "pumper" do
  action [:install, :start]
end

ubic_service "sendmail" do
  action [:stop]
end

# FIXME - copypaste!
template "/etc/logrotate.d/sendmail-pumper" do
  source "logrotate.conf.erb"
  mode 0644
  variables({
    :log => '/data/pumper/sendmail.log /data/pumper/sendmail.err.log',
    :postrotate => 'ubic reload sendmail',
  })
end

template "/etc/logrotate.d/comments2email-pumper" do
  source "logrotate.conf.erb"
  mode 0644
  variables({
    :log => '/data/pumper/comments2email.log /data/pumper/comments2email.err.log',
    :postrotate => 'ubic reload comments2email',
  })
end
