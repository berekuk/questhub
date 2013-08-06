package t::script::backend_times;

use lib 'lib';
use Play::Test;
use parent qw(Play::Test::Class);

use autodie qw(open close);
use Capture::Tiny qw(capture);

sub output :Tests {
    open my $fh, '>', 'tfiles/access.log';
    print $fh qq{127.0.0.1 [06/Aug/2013:16:30:00 +0000] "GET /api/current_user HTTP/1.1" 200 150 "-" "Mozilla/5.0" 0.110 0.100 .\n};
    print $fh qq{127.0.0.1 [06/Aug/2013:16:30:00 +0000] "GET / HTTP/1.1" 200 150 "-" "Mozilla/5.0" 0.666 0.555 .\n}; # this line will be ignored, because it's not /api/*
    print $fh qq{127.0.0.1 [06/Aug/2013:16:30:00 +0000] "GET /api/user/berekuk HTTP/1.1" 200 333 "-" "Mozilla/5.0" 0.220 0.200 .\n};
    close $fh;

    require '/play/backend/script/backend_times.pl';

    my ($stdout, $stderr) = capture {
        script::backend_times->main;
    };
    is $stdout, join '', map { "$_\n" } (
        "0.220\t0.200\tuser/berekuk",
        "0.110\t0.100\tcurrent_user",
    );
}

1;
