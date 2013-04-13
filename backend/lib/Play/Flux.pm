package Play::Flux;

use 5.010;

use Moo;
use Flux::File;
use Flux::Format::JSON;
use Flux::Storage::Memory;

use Play::Config qw(setting);

sub email {
    state $result = do {
        my $storage;
        if (setting('test')) {
            $storage = Flux::Storage::Memory->new;
        }
        else {
            $storage = Flux::File->new('/data/storage/email/log');
        }

        Flux::Format::JSON->new->wrap($storage);
    };
    return $result;
}

1;
