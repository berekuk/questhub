# There is a mongodb cookbook, but it's too generic and tries to do too many things.
apt_repository '10gen' do
    uri 'http://downloads-distro.mongodb.org/repo/ubuntu-upstart'
    distribution 'dist'
    components ['10gen']
    keyserver "keyserver.ubuntu.com"
    key "7F0CEB10"
    action :add
end
for p in %w{ mongodb mongodb-clients mongodb-dev mongodb-server }
    package 'mongodb' do
        action :purge
    end
end
package 'mongodb-10gen'

cpan_module 'Flux::File'
cpan_module 'Flux::Format::JSON'
cpan_module 'Log::Any::Adapter'
cpan_module 'MooX::Options'
cpan_module 'Package::Variant'

# needed by Email::Sender::Simple to send Amazon SES emails
cpan_module 'Authen::SASL'
cpan_module 'Net::SMTP::SSL'
cpan_module 'Email::Sender::Transport::SMTP::TLS'

package 'sendmail'

directory "/data/pumper"
directory "/data/storage"
directory "/data/images/pic" do
    recursive true
end

for storage in %w{ email events upic } do
    directory "/data/storage/#{storage}"
    file "/data/storage/#{storage}/log" do
        action :create_if_missing
    end
end

for pumper in %w{ events2email sendmail upic_fetcher } do
    template "/etc/logrotate.d/#{pumper}-pumper" do
      source "logrotate.conf.erb"
      mode 0644
      variables({
        :log => "/data/pumper/#{pumper}.log /data/pumper/#{pumper}.err.log",
        :postrotate => "ubic reload pumper.#{pumper}",
      })
    end
end

include_recipe "ubic"
if not File.exists?("/etc/ubic/service/pumper")
    ubic_service "pumper" do
      action [:install, :start]
    end
end

execute "start upic_fetcher" do
  command "ubic start pumper.upic_fetcher"
end
