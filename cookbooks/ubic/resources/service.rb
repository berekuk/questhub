actions :install, :start, :stop, :restart
default_action :install

attribute :name, :kind_of => String, :name_attribute => true

# private
attribute :service
