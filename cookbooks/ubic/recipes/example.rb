include_recipe "ubic"

ubic_service "foo" do
  action [:install, :start]
  # put your template into templates/ubic-service-foo.erb
end
