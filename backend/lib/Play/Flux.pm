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
    }

    return Flux::Format::JSON->new->wrap($storage);
}

sub email {
    state $result = _storage('email');
    return $result;
}

sub emails {
    return email();
}

sub comments {
    state $result = _storage('comments');
    return $result;
}

1;
