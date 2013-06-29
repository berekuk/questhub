#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use File::Find;
use IPC::System::Simple;
use autodie qw(:all);

system('rm -rf www-build');
system('cp -r www www-build');
system(qw{
    rm -rf
    www-build/views www-build/models
    www-build/test
    www-build/sass
    www-build/templates
    www-build/src
    www-build/css/.gitignore
    www-build/.gitignore
});

unlink $_ for glob('www-build/*.js'), glob('www-build/*.map');

system('cd www && node ./tools/r.js -o name=vendors/almond include=setup mainConfigFile=setup.js out=built.js baseUrl=. wrap=true');
rename 'www/built.js' => 'www-build/built.js';

system('cd www && sass -t compressed sass/main.scss main.min.css');
rename 'www/main.min.css' => 'www-build/css/main.css';

sub slurp {
    open my $fh, '<', shift;
    local $/;
    return scalar <$fh>;
}

sub edit_file {
    my ($filename, $sub) = @_;

    local $_ = slurp($filename);
    $sub->();

    open my $fh, '>', $filename;
    print {$fh} $_;
    close $fh;
}

edit_file('www-build/index.html', sub {
    s{\Q<script data-main="/setup" src="/vendors/require.js">\E}{<script src="/built.js">} or die "Can't find the main requirejs <script> tag";
});
