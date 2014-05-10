execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

package 'make' # for building cpan modules

include_recipe "perl"
include_recipe "questhub::frontend"
include_recipe "questhub::backend"

# for development, but listed here and not in dev.rb because these can useful in production too
package 'vim'
package 'git'
package 'screen'
package 'perl-doc'

package 'libssl-dev' # used by Net::Twitter

cpan_module 'Net::HTTP'
cpan_module 'Dancer'
cpan_module 'YAML'
cpan_module 'Module::Install' # needed by MongoDB due to packaging issues - see https://github.com/berekuk/questhub/issues/70
cpan_module 'http://cpan.metacpan.org/authors/id/F/FR/FRIEDO/MongoDB-0.503.3.tar.gz'
cpan_module 'JSON'
cpan_module 'Moo'
cpan_module 'Class::XSAccessor' # speeds up Moo
cpan_module 'Starman'
cpan_module 'Text::Markdown'
cpan_module 'Clone'
cpan_module 'Email::Sender'
cpan_module 'Log::Any'
cpan_module 'Try::Tiny'

cpan_module 'Dancer::Serializer::JSON'
cpan_module 'Dancer::Session::MongoDB'
cpan_module 'YANICK/Dancer-Plugin-Auth-Twitter-0.06.tar.gz'
cpan_module 'LWP::Protocol::https'
cpan_module 'Template'
cpan_module 'DateTime'
cpan_module 'DateTime::Format::RFC3339'

package 'libgd2-noxpm'
package 'libgd2-xpm-dev'
cpan_module 'Image::Resize'

cpan_module 'T/TO/TOBYINK/Type-Tiny-0.042.tar.gz'

directory '/data' # logs

# dancer config
template "/play/app/config.yml" do
  source "dancer-config.yml.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
      :twitter => node['play_perl']['twitter'],
      :hostport => node['play_perl']['hostport'],
      :service_name => node['play_perl']['service_name']
  })
  # TODO - notify ubic service restart
end

# global config
template "/data/config.yml" do
  source "config.yml.erb"
  owner "root"
  group "root"
  mode 0644
  variables({
      :hostport => node['play_perl']['hostport'],
      :service_name => node['play_perl']['service_name'],
      :unsubscribe_salt => node['play_perl']['unsubscribe_salt'],
      :mixpanel_token => node['play_perl']['mixpanel_token'],
      :ses => node['play_perl']['ses']
  })
  # TODO - notify ubic service restart
end

# dancer services
include_recipe "ubic"
cpan_module 'Ubic::Service::Plack'
directory "/data/dancer"
ubic_service "dancer" do
  action [:install, :start]
end
