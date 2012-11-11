ppa "berekuk/ubic"

# FIXME - we must do 'apt-get update' first!
# provisioning will fail and you'll have to fix it manually
package "ubic"

execute "setup ubic" do
    command "ubic-admin setup --batch-mode"
    not_if "test -f /etc/ubic.cfg"
end
