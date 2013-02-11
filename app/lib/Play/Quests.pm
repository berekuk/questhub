package Play::Quests;

use Moo;
use Params::Validate qw(:all);
use Play::Mongo;

use Play::Users;
use Play::Events;
use Play::Comments;

my $users = Play::Users->new;
my $events = Play::Events->new;
my $comments = Play::Comments->new;

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
    $quest->{_id} = $quest->{_id}->to_string;
    return $quest;
}

sub list {
    my $self = shift;
    my ($params) = validate_pos(@_, { type => HASHREF });

    # hmmm, 'comment_count' have a special semantics; what if we'll want to query for "quests with >N comments"?
    my $comment_count = delete $params->{comment_count};

    my @quests = $self->collection->find($params)->all;
    @quests = grep { $_->{status} ne 'deleted' } @quests;

    $self->_prepare_quest($_) for @quests;

    if ($comment_count) {
        my $comment_stat = $comments->bulk_count([
            map { $_->{_id} } @quests
        ]);

        for my $quest (@quests) {
            my $cc = $comment_stat->{$quest->{_id}};
            $quest->{comment_count} = $cc if $cc;
        }
    }

    return \@quests;
}

# returns new quest's id
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
        object_id => $id->to_string,
        object => $params,
    });

    return $id->to_string;
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

    if ($quest->{status} eq 'open' and $params->{status} and $params->{status} eq 'closed') {
        $action = 'close';
    }

    if ($quest->{status} eq 'closed' and $params->{status} and $params->{status} eq 'open') {
        $action = 'reopen';
    }

    if ($action eq 'close') {
        $users->add_points($user, $self->_quest2points($quest));
    }
    elsif ($action eq 'reopen') {
        $users->add_points($user, -$self->_quest2points($quest));
    }

    delete $quest->{_id};

    my $quest_after_update = { %$quest, %$params };
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $quest_after_update
    );

    # there are other actions, for example editing the quest description
    # TODO - should we split the update() method into several, more semantic methods?
    if ($action eq 'close' or $action eq 'reopen') {
        $events->add({
            object_type => 'quest',
            action => $action,
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

    my $quest_owner_settings = $users->get_settings($quest->{user});
    if ($quest_owner_settings->{notify_likes}) {
        my $email_body = qq[
            <p>
            <a href="http://play-perl.org/player/$user">$user</a> likes your quest <a href="http://play-perl.org/quest/$quest->{_id}">$quest->{name}</a>!<br>
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
            $quest_owner_settings->{email},
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
