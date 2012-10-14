chef-apt-repo
=============

Set up APT repositories for Debian.

Documentation
-------------

`chef-apt-repo` lets you manage apt repositories with
[Chef](http://opscode.com/chef).

### Simple example

To add an apt source for a PPA named "foobar/quux" just do this:

    ppa "foobar/quux"

To add a repo for a package named "foobar" when using `chef-apt-repo`,
you might do something like this in your chef recipes:

    apt_repo "foobar" do
      key_package "foobar-debian-keyring"
      url "http://deb.example.org/"
    end

This would add a file called `foobar.list` containing a deb line with
the specified URL to your `/etc/apt/sources.list.d` and install the
package `foobar-debian-keyring` (which is assumed to contain the GPG
keys used to sign the packages in this repo).

### Obtaining GPG keys from a keyserver

Of course you shouldn't just install random keyrings so it might be a
better idea to actually get the key you want from a keyserver before
installing the key package:

    apt_repo "foobar" do
      key_package "foobar-debian-keyring"
      url "http://deb.example.org/"
      key_id "8BADF00D"
      keyserver "keyserver.example.org" # defaults to keys.gnupg.net
    end

You could also omit the `key_package` completely, but if there is a
key package it's usually a good idea to install it, since your apt
keyring is always up-to-date that way.

### Downloading GPG keys via HTTP

In case you prefer to get your keys via HTTP instead of a keyserver,
you can do so by specifying a `key_url` in addition to the `key_id`:

    apt_repo "foobar" do
      key_id "8BADF00D"
      key_url "http://keys.example.org/foobar.gpg.key"
      url "http://deb.example.org/"
    end

(You still need the key id because it is used in order to determine
whether the key is already installed.)

### Specifying distribution and components

The commands above don't specify a distribution or a list of
components, so `distribution` defaults to the current distribution's
LSB codename (for example "lucid" or "squeeze"), while `components`
defaults to the "main" component.

If you want to specify a different distribution or components or
enable source packages, you can do so by adding the corresponding
definitions:

    apt_repo "foobar" do
      key_id "8BADF00D"
      key_package "foobar-debian-keyring"
      url "http://deb.example.org/"
      distribution "foobar-stable"
      components ["free", "non-free"]
      source_packages true
    end

This would roughly correspond to something like this:

    cat > /etc/apt/sources.list.d/foobar.list <<EOF
    deb     http://deb.example.org/ foobar-stable free non-free
    deb-src http://deb.example.org/ foobar-stable free non-free
    EOF
    apt-key adv --keyserver keys.gnupg.net --recv-keys 8BADF00D
    aptitude update
    aptitude install foobar-debian-keyring

### Real world examples

If you are interested in seeing some simple recipes that use
`chef-apt-repo` you might want to have a peek into the [recipes
directory](https://github.com/sometimesfood/chef-apt-repo/tree/master/recipes/).

Why chef-apt-repo?
------------------

`chef-apt-repo` predates similar functionality in
[Opscode's apt cookbook](https://github.com/opscode-cookbooks/apt).

While I have no plans to deprecate this cookbook just yet, I have been
working with the Opscode team to add some missing features to their
cookbook.

If you are starting a new project, I would suggest that you use the
Opscode cookbook instead of this one.

Copyright
---------

Copyright (c) 2010-2011 Sebastian Boehm. See LICENSE for details.
