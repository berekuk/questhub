package Play::Comments;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->comments;
    },
);

sub add {
    my $self = shift;
    my %params = validate(@_, {
        quest_id => { type => SCALAR },
        body => { type => SCALAR },
        author => { type => SCALAR },
    });
    my $id = $self->collection->insert(\%params);
    return $id->to_string;
}

# get all comments for a quest
# TODO - pager?
sub get {
    my $self = shift;
    my ($quest_id) = validate_pos(@_, { type => SCALAR });

    my @comments = $self->collection->find({ quest_id => $quest_id })->all;
    $_->{_id} = $_->{_id}->to_string for @comments;
    return \@comments;
}

sub remove {
    my $self = shift;
    my $params = validate(@_, {
        quest_id => { type => SCALAR },
        id => { type => SCALAR },
        user => { type => SCALAR }
    });

    my $result = $self->collection->remove(
        {
            _id => MongoDB::OID->new(value => $params->{id}),
            quest_id => $params->{quest_id},
            author => $params->{user},
        },
        { just_one => 1, safe => 1 }
    );
    die "comment not found or access denied" unless $result->{n} == 1;
    return;
}

1;
