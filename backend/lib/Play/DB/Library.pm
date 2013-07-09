package Play::DB::Library;

=head1 SYNOPSIS

    $library->add({ name => "read a book", realm => "chaos" });

=head1 DESCRIPTION

We're calling library quests "books" internally. Just because we need a name for them. (FIXME - figure out a better name.)

=cut

use 5.010;
use utf8;

use Moo;
with 'Play::DB::Role::Common';

use Play::Mongo;

use Type::Params qw( compile );
use Types::Standard qw( Undef Dict Str Optional );

sub _build_entity_name { 'book' }
sub _build_collection { Play::Mongo->db->get_collection('library') }

sub _prepare_book {
    my $self = shift;
    my ($book) = @_;
    $book->{ts} = $book->{_id}->get_time;
    $book->{_id} = $book->{_id}->to_string;

    return $book;
}

sub add {
    my $self = shift;
    state $check = compile(Dict[
        realm => Str,
        name => Str,
    ]);
    my ($params) = $check->(@_);

    my $id = $self->collection->insert($params, { safe => 1 });

    my $book = { %$params, _id => $id };
    $self->_prepare_book($book);
}

sub list {
    my $self = shift;
    state $check = compile(Undef|Dict[
        realm => Optional[Str],
    ]);
    my ($params) = $check->(@_);
    $params ||= {};

    my @books = $self->collection->find($params)->all;
    $self->_prepare_book($_) for @books;

    return \@books;
}

1;
