package Play::Quests;

use 5.010;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

use Play::Users;
use Play::Events;
use Play::Comments;

use Dancer qw(setting);

my $users = Play::Users->new;
my $events = Play::Events->new;
my $comments = Play::Comments->new;

=pod

$quest = {
    user => '...',
    status => qr/ open | closed | stalled | abandoned /,

    open->closed
    open->stalled
    open->abandoned

    closed->open
    stalled->open
    abandoned->open

    any->deleted
}

=cut

has 'collection' => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return Play::Mongo->db->get_collection('quests');
    },
);

sub _prepare_quest {
    my $self = shift;
    my ($quest) = @_;
    $quest->{ts} = $quest->{_id}->get_time;
    $quest->{_id} = $quest->{_id}->to_string;
    return $quest;
}

sub list {
    my $self = shift;
    my $params = validate(@_, {
        # find() filters
        user => { type => SCALAR, optional => 1 },
        status => { type => SCALAR, optional => 1 },
        # flag meaning "fetch comment_count too"
        comment_count => { type => BOOLEAN, optional => 1 },
        # sorting and paging
        sort => { type => SCALAR, optional => 1, regex => qr/^(leaderboard)$/ }, # only 'leaderboard' sorting is supported by now
        limit => { type => SCALAR, regex => qr/^\d+$/, optional => 1 },
        offset => { type => SCALAR, regex => qr/^\d+$/, default => 0 },
    });

    my @quests = $self->collection->query(
        {
            map { defined($params->{$_}) ? ($_ => $params->{$_}) : () } qw/ user status /
        },
        {
            sort_by => { '_id' => 1 }
        }
    )->all;
    @quests = grep { $_->{status} ne 'deleted' } @quests;

    $self->_prepare_quest($_) for @quests;

    if ($params->{comment_count} or ($params->{sort} || '') eq 'leaderboard') {
        my $comment_stat = $comments->bulk_count([
            map { $_->{_id} } @quests
        ]);

        for my $quest (@quests) {
            my $cc = $comment_stat->{$quest->{_id}};
            $quest->{comment_count} = $cc if $cc;
        }
    }

    if ($params->{sort} and $params->{sort} eq 'leaderboard') {
        # composite likes->comments order
        @quests = sort {
            my $c1 = (
                ($b->{likes} ? scalar @{ $b->{likes} } : 0)
                <=>
                ($a->{likes} ? scalar @{ $a->{likes} } : 0)
            );
            return $c1 if $c1;
            return ($b->{comment_count} || 0) <=> ($a->{comment_count} || 0);
        } @quests;
    }

    if ($params->{limit} and @quests > $params->{limit}) {
        @quests = splice @quests, $params->{offset}, $params->{limit};
    }

    return \@quests;
}

=head1 FORMAT

Events can be of different types and contain different loosely-typed fields, but they all follow the same structure:

    {
        # required fields:
        object_type => 'quest', # possible values: 'quest', 'user', 'comment'...
        action => 'add', # 'close', 'reopen'...
        author => 'berekuk', # it's usually contained in other fields as well, but is kept here for consistency and simplifying further rendering

        # optional
        object_id => '123456789000000',
        object => {
            ... # anything goes, but usually an object of 'object_type'
        }
    }

=cut
sub add {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    # validate
    # TODO - do strict validation here instead of dancer route?
    if ($params->{type}) {
        die "Unexpected quest type '$params->{type}'" unless grep { $params->{type} eq $_ } qw/ bug blog feature other /;
    }

    my $id = $self->collection->insert($params);

    $events->add({
        object_type => 'quest',
        action => 'add',
        author => $params->{user},
        object_id => $id->to_string,
        object => $params,
    });

    my $quest = { %$params, _id => $id };
    $self->_prepare_quest($quest);

    return $quest;
}

sub _quest2points {
    my $self = shift;
    my ($quest) = @_;

    my $points = 1;
    $points += scalar @{ $quest->{likes} } if $quest->{likes};
    return $points;
}

sub update {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless ($quest->{user} eq $user) {
        die "access denied";
    }

    my $action = '';

    if ($params->{status} and $params->{status} ne $quest->{status}) {
        if ($quest->{status} eq 'open' and $params->{status} eq 'closed') {
            $action = 'close';
        }
        elsif ($quest->{status} eq 'closed' and $params->{status} eq 'open') {
            $action = 'reopen';
        }
        elsif ($quest->{status} eq 'open' and $params->{status} eq 'abandoned') {
            $action = 'abandon';
        }
        elsif ($quest->{status} eq 'abandoned' and $params->{status} eq 'open') {
            $action = 'resurrect';
        }
        else {
            die "quest status transition $quest->{status} => $params->{status} is forbidden";
        }
    }

    if ($action eq 'close') {
        $users->add_points($user, $self->_quest2points($quest));
    }
    elsif ($action eq 'reopen') {
        $users->add_points($user, -$self->_quest2points($quest));
    }

    delete $quest->{_id};
    delete $quest->{ts};

    my $quest_after_update = { %$quest, %$params };
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $quest_after_update
    );

    # there are other actions, for example editing the quest description
    # TODO - should we split the update() method into several, more semantic methods?
    if ($action) {
        $events->add({
            object_type => 'quest',
            action => $action,
            author => $quest_after_update->{user},
            object_id => $id,
            object => $quest_after_update,
        });
    }

    return $id;
}

# returns the quest that was liked
sub _like_or_unlike {
    my $self = shift;
    my ($id, $user, $mode) = @_;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            user => { '$ne' => $user },
        },
        { $mode => { likes => $user } },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to like your own quest";
    }

    my $quest = $self->get($id);
    if ($quest->{status} eq 'closed') {
        # add points retroactively
        # FIXME - there's a race condition here somewhere
        $users->add_points(
            $quest->{user},
            (($mode eq '$pull') ? -1 : 1)
        );
    }

    return $quest;
}

sub like {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    my $quest = $self->_like_or_unlike($id, $user, '$addToSet');

    if (my $email = $users->get_email($quest->{user}, 'notify_likes')) {
        my $email_body = qq[
            <p>
            <a href="http://].setting('hostport').qq[/player/$user">$user</a> likes your quest <a href="http://].setting('hostport').qq[/quest/$quest->{_id}">$quest->{name}</a>!<br>
            </p>
        ];
        if ($quest->{status} eq 'open') {
            $email_body .= q[
                <p>
                Reward for completing this quest is now ].$self->_quest2points($quest).q[.
                </p>
            ];
        }
        elsif ($quest->{status} eq 'closed') {
            $email_body .= q[
                <p>
                You already completed this quest! Now you get one more point for your great deed.
                </p>
            ];
        }

        # TODO - different bodies depending on quest status
        $events->email(
            $email,
            "$user likes your quest '$quest->{name}'!",
            $email_body,
        );
    }

    return;
}

sub unlike {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });

    $self->_like_or_unlike($id, $user, '$pull');
    return;
}

sub remove {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless ($quest->{user} eq $user) {
        die "access denied";
    }

    if ($quest->{status} eq 'closed') {
        $users->add_points($user, -$self->_quest2points($quest));
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { %$quest, status => 'deleted' },
        { safe => 1 }
    );
}

sub get {
    my $self = shift;
    my ($id) = validate_pos(@_, { type => SCALAR });

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "quest $id not found" unless $quest;
    die "quest $id is deleted" if $quest->{status} eq 'deleted';
    $self->_prepare_quest($quest);
    return $quest;
}

1;
