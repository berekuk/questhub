cpan_module 'Flux::File'
cpan_module 'Flux::Format::JSON'
cpan_module 'Log::Any::Adapter'
cpan_module 'MooX::Options'
cpan_module 'Package::Variant'

# needed by Email::Sender::Simple to send Amazon SES emails
cpan_module 'Authen::SASL'
cpan_module 'Net::SMTP::SSL'

package 'sendmail'

directory "/data/pumper"
directory "/data/storage"

# FIXME - copypaste!
directory "/data/storage/email"
file "/data/storage/email/log" do
    action :create_if_missing
end

directory "/data/storage/events"
file "/data/storage/events/log" do
    action :create_if_missing
end

include_recipe "ubic"
if not File.exists?("/etc/ubic/service/pumper")
    ubic_service "pumper" do
      action [:install, :start]
    end
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

template "/etc/logrotate.d/events2email-pumper" do
  source "logrotate.conf.erb"
  mode 0644
  variables({
    :log => '/data/pumper/events2email.log /data/pumper/events2email.err.log',
    :postrotate => 'ubic reload events2email',
  })
end

if File.exists?("/etc/logrotate.d/comments2email-pumper")
  execute "stop comments2email" do
    command "ubic stop pumper.comments2email"
  end
  file "/etc/logrotate.d/comments2email-pumper" do
    action :delete
  end
end

execute "start events2email" do
  command "ubic start pumper.events2email"
end
