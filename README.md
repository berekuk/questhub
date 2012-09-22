play-perl.org
=========

http://play-perl.org sources.

Quick start
=========

1. Install http://vagrantup.com/
2. Clone this repo
3. Run `vagrant up`
4. Run `vagrant ssh`
5. cd to `/vagrant/app` and start hacking!

You can edit `/vagrant` contents from the VM or from your own host. The changes are mirrored.

How everything is configured
=========

nginx is a http proxy. Inside the VM, it proxies 80 => 3000 port.
You can start your app by running `bin/app.pl` from `/vagrant/app`.
It listens to 3000 port and doesn't detach from the terminal.

Port 80 from VM proxies to port 3000 on your localhost.
So, after starting VM using `vagrant up`, you can access nginx by going to http://localhost:3000 in your browser.

We'll configure the dancer app to start as a service later.

How to reconfigure the environment
=========

You can install new packages in the VM using `sudo apt-get install ...`, as usual.

The VM contents is configured with [Chef](http://www.opscode.com/chef/).
So you should also share your configuration with other users by editing `cookbooks/play-perl/recipes/default.rb` file.

To add a new debian package to chef configuration, just add a `package 'PACKAGE_NAME'` line to the `default.rb` recipe.
To add an arbitrary imperative initialization code, use a `bash` block:

```
bash "restart nginx" do
  code <<-EOH
  ANY SHELL CODE
EOH
end
```

You can run `vagrant provision` to redeploy the chef configuration.
