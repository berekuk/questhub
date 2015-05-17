# for running jasmine tests from CLI
include_recipe "phantomjs"

package 'sqlite3'
package 'libsqlite3-dev'
package 'g++'
gem_package 'i18n' do
  version '0.6.11'
end
gem_package 'mailcatcher' do
  version '0.5.12'
end
ubic_service "mailcatcher" do
  action [:install, :start]
end
