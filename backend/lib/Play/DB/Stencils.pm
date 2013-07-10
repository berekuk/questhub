package Play::DB::Stencils;

=head1 SYNOPSIS

    $stensils->add({ name => "read a book", realm => "chaos" });

=cut

use 5.010;
use utf8;

use Moo;
with 'Play::DB::Role::Common';

use Play::Mongo;

use Type::Params qw( compile );
use Types::Standard qw( Undef Dict Str Optional );
use Play::Types qw( Id Login Realm );

sub _prepare {
    my $self = shift;
    my ($stencil) = @_;
    $stencil->{ts} = $stencil->{_id}->get_time;
    $stencil->{_id} = $stencil->{_id}->to_string;

    return $stencil;
}

sub add {
    my $self = shift;
    state $check = compile(Dict[
        realm => Realm,
        name => Str,
        author => Login,
    ]);
    my ($params) = $check->(@_);

    my $id = $self->collection->insert($params, { safe => 1 });

    my $stencil = { %$params, _id => $id };
    $self->_prepare($stencil);
}

sub list {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Optional[Realm],
        author => Optional[Login],
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    my @stencils = $self->collection->find($params)->all;
    $self->_prepare($_) for @stencils;

    return \@stencils;
}

sub get {
    my $self = shift;
    state $check = compile(Id);
    my ($id) = $check->(@_);

    my $stencil = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });

    die "stencil $id not found" unless $stencil;
    $self->_prepare($stencil);
    return $stencil;
}

1;
