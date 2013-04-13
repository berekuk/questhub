package Moo::Runnable;

use Moo::Role;

requires 'run';

sub run_script {
    my $class = shift;

    if (caller(1)) {
        return $class;
    }
    else {
        # if I will ever release Moo::Runnable as a separate distro, this will have to go somewhere else
        require Log::Any::Adapter;
        Log::Any::Adapter->import('File', '/dev/stdout');

        $class->new->run;
    }
}

1;
