action :start do
  execute "start ubic service #{new_resource.name}" do
    not_if "ubic status #{new_resource.name}"
    command "ubic start #{new_resource.name}"
  end
end

action :stop do
  execute "stop ubic service #{new_resource.name}" do
    only_if "ubic status #{new_resource.name}"
    command "ubic stop #{new_resource.name}"
  end
end

action :restart do
  execute "restart ubic service #{new_resource.name}" do
    command "ubic restart #{new_resource.name}"
  end
end

action :install do
  template "/etc/ubic/service/#{new_resource.name}" do
    source "ubic-service-#{new_resource.name}.erb"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, "ubic_service[#{new_resource.name}]" # FIXME - doesn't work for some reason, see https://gist.github.com/3889852
  end
end
