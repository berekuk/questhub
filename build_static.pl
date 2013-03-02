#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use File::Find;
use IPC::System::Simple;
use autodie qw(:all);

system('rm -rf www-build');
system('cp -r www www-build');

my $index_html = qx(cat www-build/index.html);

sub slurp {
    open my $fh, '<', shift;
    local $/;
    return scalar <$fh>;
}

open my $scripts_fh, '>', 'www-build/scripts.js';
while ($index_html =~ s{^\s*<script src="(/(?:models|views)/[^"]+\.js)"></script>$}{}m) {
    print {$scripts_fh} slurp("www/$1");
}
close $scripts_fh;

if ($index_html =~ m{"/(?:models|views)/}) {
    die "oops, looks like we missed some <script> tag";
}

system(q{rm -rf www-build/views www-build/models});

$index_html =~ s{(^\s*<script src="/app\.js"></script>\n$)}{\n    <script src="/scripts.js"></script>\n$1}m or die "no app.js include found";

open my $fh, '>', 'www-build/index.html';
print {$fh} $index_html;
close $fh;
