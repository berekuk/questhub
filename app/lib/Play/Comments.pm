package Play::Comments;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;
use Text::Markdown qw(markdown);

my $events = Play::Events->new;
my $quests = Play::Quests->new;
my $users = Play::Users->new;

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('comments');
    },
);

sub _body_html {
    my ($body) = @_;
    my $html = markdown($body);
    $html =~ s{^<p>}{};
    $html =~ s{</p>$}{};
    return $html;
}

sub _prepare_comment {
    my $self = shift;
    my ($comment) = @_;
    $comment->{ts} = $comment->{_id}->get_time;
    $comment->{_id} = $comment->{_id}->to_string;
    $comment->{body_html} = _body_html($comment->{body});
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

    my $quest = $quests->get($params{quest_id});

    $events->add({
        object_type => 'comment',
        action => 'add',
        object_id => $id->to_string,
        object => {
            %params,
            body_html => _body_html($params{body}), # markdown for comments in the feed is cached forever, to simplify the events storage and frontend logic
            quest => $quest,
        },
    });
    my $user_settings = $users->get_settings($quest->{user});
    if ($user_settings->{notify_comments} and $params{author} ne $quest->{user}) {
        $events->email(
            $user_settings->{email},
            "$params{author} commented on '$quest->{name}'",
            "Body: [$params{body}]",
        );
    }

    return { _id => $id->to_string, body_html => _body_html($params{body}) };
}

# get all comments for a quest
# TODO - pager?
sub get {
    my $self = shift;
    my ($quest_id) = validate_pos(@_, { type => SCALAR });

    my @comments = $self->collection->find({ quest_id => $quest_id })->all;
    $self->_prepare_comment($_) for @comments;

    @comments = sort { $a->{ts} <=> $b->{ts} } @comments; # FIXME - sort on mongodb side
    return \@comments;
}

sub get_one {
    my $self = shift;
    my ($comment_id) = validate_pos(@_, { type => SCALAR });

    my $comment = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $comment_id)
    });
    die "comment $comment_id not found" unless $comment;
    $self->_prepare_comment($comment);
    return $comment;
}

# get number of comments for each quest in given set
sub bulk_count {
    my $self = shift;
    my ($ids) = validate_pos(@_, { type => ARRAYREF });

    # TODO - upgrade MongoDB to 2.2+ and use aggregation
    my @comments = $self->collection->find({ quest_id => { '$in' => $ids } })->all;
    my %stat;
    for (@comments) {
        $stat{ $_->{quest_id} }++;
    }
    return \%stat;
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

sub update {
    my $self = shift;
    my $params = validate(@_, {
        quest_id => { type => SCALAR },
        id => { type => SCALAR },
        body => { type => SCALAR },
        user => { type => SCALAR }
    });
    my $id = delete $params->{id};
    delete $params->{quest_id}; # ignore it for now

    my $comment = $self->get_one($id);
    unless ($comment->{author} eq $params->{user}) {
        die "access denied";
    }

    delete $comment->{_id};
    my $comment_after_update = { %$comment, %$params };
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $comment_after_update
    );

    return $id;
}

1;
