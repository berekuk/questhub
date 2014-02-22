directory '/data/ssl'
for f in %w{ PositiveSSLCA2.crt dhparam_4096.pem questhub.key questhub_io.crt  } do
    cookbook_file "/data/ssl/#{f}" do
      source "ssl/#{f}"
      mode 0400
      owner "root"
      group "root"
    end
end

