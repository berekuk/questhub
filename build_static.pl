#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use File::Find;
use IPC::System::Simple;
use autodie qw(:all);

system('rm -rf www-build');
system('cp -r www www-build');
system(q{rm -rf www-build/views www-build/models www-build/test www-build/*.js});

system('cd www && node ./tools/r.js -o name=setup mainConfigFile=setup.js out=built.js baseUrl=.');
rename 'www/built.js' => 'www-build/built.js';

sub slurp {
    open my $fh, '<', shift;
    local $/;
    return scalar <$fh>;
}

my $index_html = slurp('www-build/index.html');
$index_html =~ s{<script data-main="/setup"}{<script data-main="/built"} or die "Can't find the main requirejs <script> tag";

open my $fh, '>', 'www-build/index.html';
print {$fh} $index_html;
close $fh;
