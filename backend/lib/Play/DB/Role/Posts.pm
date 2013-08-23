package Play::DB::Role::Posts;

=head1 DB OBJECT FORMAT

  {
      'entity': / quest | stencil /,
      'bump': 'timestamp',
      'name': 'entity name',
      'description': 'entity description',
      'author': 'foo',
      'realm': 'europe',
      'points': 3,
      ... # entity-specific fields
  }

=cut

use 5.014;
use utf8;

use Moo::Role;
with
    'Play::DB::Role::Common',
    'Play::DB::Role::Bumpable';

use Type::Params qw( compile );
use Types::Standard qw( ArrayRef HashRef Str );
use Play::Types qw( Id );

use MongoDB::OID;

has 'entity' => (
    is => 'lazy',
    required => 1,
    isa => Str,
);

sub prepare {
    my $self = shift;
    my ($post) = @_;
    $post->{ts} = $post->{_id}->get_time;
    $post->{_id} = $post->{_id}->to_string;

    return $post;
}

=item B<get($id)>

=cut
sub get {
    my $self = shift;
    state $check = compile(Id);
    my ($id) = $check->(@_);

    my $entity = $self->entity;
    my $post = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id),
        entity => $entity,
    });
    die "$entity $id not found" unless $post;
    if (
        $post->{status} # stencils don't have a status yet
        and $post->{status} eq 'deleted'
    ) {
        die "$entity $id is deleted";
    }

    $post = $self->prepare($post);
    return $post;
}

=item B<bulk_get(\@ids)>

=cut
sub bulk_get {
    my $self = shift;
    state $check = compile(ArrayRef[Id]);
    my ($ids) = $check->(@_);

    my @posts = $self->collection->find({
        '_id' => {
            '$in' => [
                map { MongoDB::OID->new(value => $_) } @$ids
            ]
        }
    })->all;
    @posts = grep { ($_->{status} || '') ne 'deleted' } @posts;
    $self->prepare($_) for @posts;

    return {
        map {
            $_->{_id} => $_
        } @posts
    };
}

sub inner_add {
    my $self = shift;
    state $check = compile(HashRef);
    my ($params) = $check->(@_);

    $params->{bump} = time;
    $params->{entity} = $self->entity;

    my $id = $self->collection->insert($params, { safe => 1 });
    my $post = { %$params, _id => $id };
    $self->prepare($post);

    return $post;
}

1;
