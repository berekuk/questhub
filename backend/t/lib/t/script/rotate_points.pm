package t::script::rotate_points;

use lib 'lib';
use Play::Test;
use parent qw(Play::Test::Class);

use autodie qw(open close);
use Capture::Tiny qw(capture);
use Play::DB qw(db);

sub startup :Test(startup) {
    reset_db();
}

sub output :Tests {
    db->users->add({ login => 'foo' });
    db->users->add({ login => 'bar' });
    require '/play/backend/script/rotate_points.pl';

    my ($stdout, $stderr) = capture {
        script::rotate_points->main;
    };
    is $stdout, "2 rotated\n";
    is $stderr, "";
}

1;
