package Play::Pumper::Multiservice;

use strict;
use warnings;

use Ubic::Multiservice::Simple;
use Ubic::Service::SimpleDaemon;

use File::Basename qw(basename);

sub new {
    my @pumpers = glob '/play/backend/pumper/*.pl';
    @pumpers = map { basename($_) } @pumpers;
    s{\.pl$}{} or die "unexpected name '$_'" for @pumpers;
    return Ubic::Multiservice::Simple->new({
        map {
            $_ => Ubic::Service::SimpleDaemon->new({
                bin => "/play/backend/pumper/$_.pl --loop --sleep-period=5",
                stdout => "/data/pumper/$_.log",
                stderr => "/data/pumper/$_.err.log",
                ubic_log => "/data/pumper/$_.ubic.log",
                reload_signal => 'HUP',
            })
        } @pumpers
    });
}

1;
