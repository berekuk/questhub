ppa "berekuk/ubic"
package "ubic"

execute "setup ubic" do
    command "ubic-admin setup --batch-mode"
    not_if "test -f /etc/ubic.cfg"
end
