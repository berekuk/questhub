package Play::Config;

use 5.014;
use warnings;

use parent qw(Exporter);
our @EXPORT_OK = qw( setting );

use YAML::Tiny;

my $config;
sub setting {
    my ($name) = @_;

    unless ($config) {
        # ENV overloading is for tests
        my $yaml = YAML::Tiny->read($ENV{PLAY_CONFIG_FILE} || '/data/config.yml');
        $config = $yaml->[0];
    }
    return $config->{$name};
}

1;
