package Play::Comments;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;
use Text::Markdown qw(markdown);

use Dancer qw(setting);

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

sub pp_markdown {
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
    $comment->{body_html} = pp_markdown($comment->{body});
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

    my $body_html = pp_markdown($params{body}); # markdown for comments in the feed is cached forever, to simplify the events storage and frontend logic

    $events->add({
        object_type => 'comment',
        action => 'add',
        author => $params->{author},
        object_id => $id->to_string,
        object => {
            %params,
            body_html => $body_html,
            quest => $quest,
        },
    });

    if ($params{author} ne $quest->{user}) {
        my $email = $users->get_email($quest->{user}, 'notify_comments');
        if ($email) {
            # TODO - quoting
            # TODO - unsubscribe link
            my $email_body = qq[
                <p>
                <a href="http://].setting('hostport').qq[/player/$params{author}">$params{author}</a> commented on your quest <a href="http://].setting('hostport').qq[/quest/$params{quest_id}">$quest->{name}</a>:
                <hr>
                </p>
                <p>$body_html</p>
            ];
            $events->email(
                $email,
                "$params{author} commented on '$quest->{name}'",
                $email_body,
            );
        }
    }

    return { _id => $id->to_string, body_html => pp_markdown($params{body}) };
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
