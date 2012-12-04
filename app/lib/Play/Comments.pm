package Play::Comments;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;
use Text::Markdown qw(markdown);

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->comments;
    },
);

sub _prepare_comment {
    my $self = shift;
    my ($comment) = @_;
    $comment->{_id} = $comment->{_id}->to_string;
    $comment->{body_html} = markdown($comment->{body});
    return $comment;
}

sub add {
    my $self = shift;
    my %params = validate(@_, {
        quest_id => { type => SCALAR },
        body => { type => SCALAR },
        author => { type => SCALAR },
    });
    my $id = $self->collection->insert(\%params);
    return { _id => $id->to_string, body_html => markdown($params{body}) };
}

# get all comments for a quest
# TODO - pager?
sub get {
    my $self = shift;
    my ($quest_id) = validate_pos(@_, { type => SCALAR });

    my @comments = $self->collection->find({ quest_id => $quest_id })->all;
    $self->_prepare_comment($_) for @comments;
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
