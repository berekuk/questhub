package Play::DB::Quests;

=head1 SYNOPSIS

    $quests->add({ ...fields... });

    $quests->list({ ...options... });

    $quests->get($object_id);

    $quests->remove($object_id, { user => $owner });

    $quests->like($object_id, $liker);
    $quests->unlike($object_id, $liker);

    $quests->update($object_id, { ...new fields... });

=head1 OBJECT FORMAT

  $quest = {
      team => ['...'],
      status => qr/ open | closed | stalled | abandoned /,
      ...
  }

=head1 DESCRIPTION

Allowed status transitions:

    open => closed
    open => stalled         # 'stalled' is not implemented yet
    open => abandoned

    closed => open
    stalled => open         # 'stalled' is not implemented yet
    abandoned => open

    * => deleted

=cut

use 5.010;
use utf8;

use Moo;

use Types::Standard qw(Undef Bool Int Str Optional Dict ArrayRef HashRef);
use Type::Params qw(validate);

use Play::Config qw(setting);
use Play::DB qw(db);

use Play::DB::Role::PushPull;
with
    'Play::DB::Role::Common',
    PushPull(
        field => 'likes',
        except_field => 'team', # team members can't like their own quest
        push_method => 'like',
        pull_method => 'unlike',
    ),
    PushPull(
        field => 'watchers',
        except_field => 'team', # team members are always watching a quest
        push_method => 'watch',
        pull_method => 'unwatch',
    );

sub _prepare_quest {
    my $self = shift;
    my ($quest) = @_;
    $quest->{ts} = $quest->{_id}->get_time;
    $quest->{_id} = $quest->{_id}->to_string;

    $quest->{team} ||= [];

    return $quest;
}

sub get {
    my $self = shift;
    my ($id) = validate(\@_, Str);

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "quest $id not found" unless $quest;
    die "quest $id is deleted" if $quest->{status} eq 'deleted';
    $self->_prepare_quest($quest);
    return $quest;
}

sub bulk_get {
    my $self = shift;
    my ($ids) = validate(\@_, ArrayRef[Str]);

    my @quests = $self->collection->find({
        '_id' => {
            '$in' => [
                map { MongoDB::OID->new(value => $_) } @$ids
            ]
        }
    })->all;
    @quests = grep { $_->{status} ne 'deleted' } @quests;
    $self->_prepare_quest($_) for @quests;

    return {
        map {
            $_->{_id} => $_
        } @quests
    };
}

sub list {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        # find() filters
        user => Optional[Str],
        realm => Str,
        unclaimed => Optional[Bool],
        status => Optional[Str],
        # flag meaning "fetch comment_count too"
        comment_count => Optional[Bool],
        # sorting and paging
        sort => Optional[Str], # regex => qr/^(leaderboard|ts)$/ }
        order => Optional[Str], # regex => qr/^asc|desc$/, default => 'desc' },
        limit => Optional[Int],
        offset => Optional[Int],
        tags => Optional[Str],
        watchers => Optional[Str],
    ]);
    $params ||= {};
    $params->{order} //= 'desc';
    $params->{offset} //= 0;

    if (($params->{status} || '') eq 'deleted') {
        die "Can't list deleted quests";
    }

    my $query = {
            map { defined($params->{$_}) ? ($_ => $params->{$_}) : () } qw/ status tags watchers realm /
    };
    $query->{team} = $params->{user} if defined $params->{user};
    $query->{status} ||= { '$ne' => 'deleted' };

    if (delete $params->{unclaimed}) {
        die "Can't set both 'user' and 'unclaimed' at the same time" if defined $params->{user};
        $query->{team} = { '$size' => 0 };
    }

    my $cursor = $self->collection->query($query);

    # if sort=leaderboard, we have to fetch everything and sort manually
    if (not $params->{sort}) {
        my $order_flag = ($params->{order} eq 'asc' ? 1 : -1);
        $cursor = $cursor->sort({ _id => $order_flag });

        $cursor = $cursor->limit($params->{limit}) if $params->{limit};
        $cursor = $cursor->skip($params->{offset}) if $params->{offset};
    }

    my @quests = $cursor->all;
    $self->_prepare_quest($_) for @quests;

    if ($params->{comment_count} or ($params->{sort} || '') eq 'leaderboard') {
        my $comment_stat = db->comments->bulk_count([
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

    if ($params->{sort}) {
        # manual limit/offset
        if ($params->{limit} and @quests > $params->{limit}) {
            @quests = splice @quests, $params->{offset}, $params->{limit};
        }
    }

    return \@quests;
}

sub add {
    my $self = shift;
    my ($params) = validate(\@_, Dict[
        realm => Str,
        name => Str,
        user => Optional[Str],
        team => Optional[ArrayRef[Str]],
        tags => Optional[ArrayRef[Str]],
        status => Optional[Str],
    ]);
    $params->{status} //= 'open';

    if (defined $params->{team}) {
        if (defined $params->{user}) {
            die "only one of 'user' and 'team' should be set";
        }
        die "team size should be 1 on quest creation" unless scalar @{ $params->{team} } == 1;
    }
    else {
        if (not defined $params->{user}) {
            die "one of 'user' and 'team' should be set";
        }
        $params->{team} = [ delete $params->{user} ];
    }

    for my $team_member (@{ $params->{team} }) {
        my $user = db->users->get_by_login($team_member) or die "User '$team_member' not found";
        unless (grep { $_ eq $params->{realm} } @{ $user->{realms} }) {
            db->users->join_realm($team_member, $params->{realm});
        }
    }

    if ($params->{tags}) {
        die "Tags should be arrayref" unless ref($params->{tags}) eq 'ARRAY';
        $params->{tags} = [ sort @{ $params->{tags} } ];
    }

    $params->{author} = $params->{team}[0];
    my $id = $self->collection->insert($params, { safe => 1 });

    my $quest = { %$params, _id => $id };
    $self->_prepare_quest($quest);

    db->events->add({
        object_type => 'quest',
        action => 'add',
        author => $params->{author},
        object_id => $id->to_string,
        realm => $params->{realm},
    });

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
    my ($id, $params) = validate(\@_, Str, HashRef);

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless (grep { $_ eq $user } @{$quest->{team}}) {
        die "access denied";
    }

    if ($params->{tags}) {
        $params->{tags} = [ sort @{ $params->{tags} } ];
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

    {
        my $points = $self->_quest2points($quest);
        if ($action eq 'close') {
            db->users->add_points($_, $points, $quest->{realm}) for @{$quest->{team}};
        }
        elsif ($action eq 'reopen') {
            db->users->add_points($_, -$points, $quest->{realm}) for @{$quest->{team}};
        }
    }

    delete $quest->{_id};
    delete $quest->{ts};

    my $quest_after_update = { %$quest, %$params };
    delete $quest_after_update->{invitee} if $params->{status} and $params->{status} ne 'open';

    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        $quest_after_update,
        { safe => 1 }
    );

    # there are other actions, for example editing the quest description
    # TODO - should we split the update() method into several, more semantic methods?
    if ($action) {
        db->events->add({
            object_type => 'quest',
            action => $action,
            author => $user,
            object_id => $id,
            object => $quest_after_update,
            realm => $quest->{realm}
        });
    }

    return $id;
}

after 'like' => sub {
    my $self = shift;
    my ($id, $user) = @_;

    my $quest = $self->get($id);

    return unless $quest->{team} and scalar @{ $quest->{team} };
    my @team = @{ $quest->{team} };

    if ($quest->{status} eq 'closed') {
        db->users->add_points($_, 1, $quest->{realm}) for @team;
    }

    # TODO - events2email
    if (my $email = db->users->get_email($team[0], 'notify_likes')) {
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
        db->events->email(
            $email,
            "$user likes your quest '$quest->{name}'!",
            $email_body,
        );
    }
};
after 'unlike' => sub {
    my $self = shift;
    my ($id, $user) = @_;

    my $quest = $self->get($id);
    return unless $quest->{team} and scalar @{ $quest->{team} };
    my @team = @{ $quest->{team} };

    if ($quest->{status} eq 'closed') {
        db->users->add_points($_, -1, $quest->{realm}) for @team;
    }
};

sub remove {
    my $self = shift;
    my ($id, $params) = validate(\@_, Str, HashRef);

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless (grep { $_ eq $user } @{ $quest->{team} }) {
        die "access denied";
    }

    if ($quest->{status} eq 'closed') {
        db->users->add_points($_, -$self->_quest2points($quest), $quest->{realm}) for @{$quest->{team}};
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { '$set' => { status => 'deleted' } },
        { safe => 1 }
    );
}

sub invite {
    my $self = shift;
    my ($id, $user, $actor) = validate(\@_, Str, Str, Str);
    db->users->get_by_login($user) or die "Invitee '$user' not found";

    my $quest = $self->get($id);

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            '$and' => [
                { team => { '$ne' => $user } }, # team members can't invite themselves to join a quest
                { team => $actor },  # only team members can invite other players
            ],
            invitee => { '$ne' => $user },
            status => 'open',
        },
        {
            '$addToSet' => { invitee => $user },
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to invite to your own quest";
    }

    db->events->add({
        object_type => 'quest',
        action => 'invite',
        author => $actor,
        object_id => $id,
        object => {
            quest => $quest,
            invitee => $user,
        },
        realm => $quest->{realm}
    });

    return;
}

sub uninvite {
    my $self = shift;
    my ($id, $user, $actor) = validate(\@_, Str, Str, Str);
    db->users->get_by_login($user) or die "Invitee '$user' not found";

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            '$and' => [
                { team => { '$ne' => $user } },
                { team => $actor },
            ],
            invitee => $user,
        },
        {
            '$pull' => { invitee => $user },
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to uninvite to your own quest";
    }
    return;
}

sub join {
    my $self = shift;
    my ($id, $user) = validate(\@_,
        Str,
        Str,
    );
    die "only non-empty users can join quests" unless length $user; # FIXME - use Type::Tiny instead

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            '$or' => [
                { invitee => $user },
                { team => { '$size' => 0 } },
            ],
            status => 'open',
        },
        {
            '$addToSet' => { team => $user },
            '$pull' => {
                likes => $user, # can't like your own quest
                invitee => $user,
            },
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to join a quest without invitation";
    }
}

sub leave {
    my $self = shift;
    my ($id, $user) = validate(\@_, Str, Str);
    die "only non-empty users can join quests" unless length $user;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            team => $user,
        },
        {
            '$pull' => { team => $user }
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to leave quest you don't own";
    }
}

1;
