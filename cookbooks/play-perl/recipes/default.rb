require_recipe "mongodb"

package 'vim'
package 'git'
package 'libdancer-perl'
package 'nginx'

include_recipe "mongodb::default"

template "/etc/resolv.conf" do
  source "resolv.conf.erb"
  owner "root"
  group "root"
  mode 0644
end
