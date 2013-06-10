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
