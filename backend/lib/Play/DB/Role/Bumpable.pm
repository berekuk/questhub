package Play::DB::Role::Bumpable;

use 5.014;
use utf8;

use Moo::Role;
with 'Play::DB::Role::Common';

use Type::Params qw( compile );
use Play::Types qw(Id);
use MongoDB::OID;

sub bump {
    my $self = shift;
    state $check = compile(Id);
    my ($id) = $check->(@_);

    $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
        },
        {
            '$set' => { bump => time },
        },
        { safe => 1 }
    );
}

1;
