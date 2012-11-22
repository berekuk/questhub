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

1;
