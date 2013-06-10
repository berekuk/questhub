package Play::Flux;

use 5.010;

use Moo;
use Flux::File;
use Flux::Format::JSON;
use Flux::Storage::Memory;

use Play::Config qw(setting);

sub _storage {
    my ($name) = @_;

    my $storage;
    if (setting('test')) {
        $storage = Flux::Storage::Memory->new;
    }
    else {
        $storage = Flux::File->new("/data/storage/$name/log");
        # FIXME - move from Flux::File to more advanced storage with named clients
    }

    return Flux::Format::JSON->new->wrap($storage);
}

for my $name (qw( email comments events upic )) {
    no strict 'refs';
    *{$name} = sub {
        return state $result = _storage($name);
    };
}

1;
