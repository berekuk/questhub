play-perl.org
=========

http://play-perl.org sources.

Quick start
=========

1. Install http://vagrantup.com/
2. Clone this repo
3. Run `vagrant up`.
Due to the bug in Ubic cookbook ([#63](https://github.com/berekuk/play-perl/issues/63)), this step will fail. Do `vagrant ssh`, run `sudo apt-get update` inside the VM, and then reconfigure the VM with `vagrant provision`.
4. Go to http://localhost:3001 in your browser.

Run `vagrant ssh` to access your VM.

How everything is configured
=========

nginx listens to 80 and 81 ports. Port 80 is for production, 81 is for development.
It serves static html/css/js files from `www` folder, except for `/api` calls, which it proxies to 3000 or 3001 ports.
So `:80/api` is proxied to `:3000/api`, and `:81/api` is proxied to `:3001/api`.

There are two Dancer instances, one for production on `:3000` and one for development on `:3001`.
Both are running as Ubic services.
Development Dancer instance should reload code changes automatically, thanks to Dancer's `auto_reload` option.
To reload the production instance, run `sudo ubic restart dancer` inside the VM.

Port 80 from VM is forwarded to port 3000 on your localhost, and port 81 to 3001.
So, after starting VM using `vagrant up`, you can access the development instance by going to http://localhost:3001 in your browser.

Source code is stored (mounted) in `/play`. It's also mounted into `/vagrant`, but you shouldn't reference `/vagrant` dir in the code, because there's no `/vagrant` in production.

Logs and other data, except for mongodb, is in `/data`. Nginx logs are in `/data/access.log` and `/data/error.log`. Dancer logs are in `/data/dancer` and `/data/dancer-dev`.

How to reconfigure the environment
=========

The VM contents is configured with [Chef](http://www.opscode.com/chef/).
If you need a new debian package, add `package %package_name%` line to `cookbooks/play-perl/recipes/default.rb` file.
If you need a new CPAN module, add `cpan_module %module_name%` line to `cookbooks/play-perl/recipes/default.rb` file.

You can re-deploy a new chef configuration into an existing VM by running `vagrant provision`.

=========

## API

See `app/api.txt` for backend API documentation.

[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/799a7f93ca5a43d864a4743b54ff2402 "githalytics.com")](http://githalytics.com/berekuk/Ubic)
