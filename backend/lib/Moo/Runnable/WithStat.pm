package Moo::Runnable::WithStat;

use 5.010;

use Moo::Role;
with 'Moo::Runnable';

use Log::Any '$log';

has 'stat' => (
    is => 'lazy',
    default => sub { {} },
    clearer => '_clear_stat',
);

sub add_stat {
    my $self = shift;
    my ($type, $count) = @_;
    $count //= 1;

    $self->stat->{$type} += $count;
}

# TODO - Package::Variant and allow to specify any "main_method"
before 'run_once' => sub {
    my $self = shift;
    $self->_clear_stat;
};

after 'run_once' => sub {
    my $self = shift;
    my %stat = %{ $self->stat };
    if (%stat) {
        $log->info(join ', ', map { "$stat{$_} $_" } sort keys %stat);
    }
};

1;
