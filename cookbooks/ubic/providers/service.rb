action :install do
  template "/etc/ubic/service/#{new_resource.name}" do
    source "ubic-service-#{new_resource.name}.erb"
#    cookbook new_resource.cookbook if new_resource.cookbook
    owner "root"
    group "root"
    mode "0644"
  end

  s = service "ubic-service-#{new_resource.name}" do
    start_command "ubic start #{new_resource.name}"
    stop_command "ubic stop #{new_resource.name}"
    restart_command "ubic restart #{new_resource.name}"
  end
  new_resource.service(s)
end

[:start, :stop, :restart].each do |a|
  action a do
    new_resource.service.run_action(a)
  end
end
