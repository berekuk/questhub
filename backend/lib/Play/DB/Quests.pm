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
      user => '...',
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

use Params::Validate qw(:all);
use Play::Config qw(setting);

use Play::DB qw(db);

use Play::DB::Role::PushPull;
with
    'Play::DB::Role::Common',
    PushPull(field => 'likes', except_field => 'user', push_method => 'like', pull_method => 'unlike'),
    PushPull(field => 'watchers', except_field => 'user', push_method => 'watch', pull_method => 'unwatch');

sub _prepare_quest {
    my $self = shift;
    my ($quest) = @_;
    $quest->{ts} = $quest->{_id}->get_time;
    $quest->{_id} = $quest->{_id}->to_string;

    if (length $quest->{user}) {
        $quest->{team} = [$quest->{user}];
    }
    else {
        $quest->{team} = [];
    }

    return $quest;
}

sub list {
    my $self = shift;
    my $params = validate(@_, {
        # find() filters
        user => { type => SCALAR, optional => 1 },
        unclaimed => { type => BOOLEAN, optional => 1 },
        status => { type => SCALAR, optional => 1 },
        # flag meaning "fetch comment_count too"
        comment_count => { type => BOOLEAN, optional => 1 },
        # sorting and paging
        sort => { type => SCALAR, optional => 1, regex => qr/^(leaderboard|ts)$/ },
        order => { type => SCALAR, regex => qr/^asc|desc$/, default => 'desc' },
        limit => { type => SCALAR, regex => qr/^\d+$/, optional => 1 },
        offset => { type => SCALAR, regex => qr/^\d+$/, default => 0 },
        tags => { type => SCALAR, optional => 1 },
        watchers => { type => SCALAR, optional => 1 },
    });

    if (($params->{status} || '') eq 'deleted') {
        die "Can't list deleted quests";
    }

    my $query = {
            map { defined($params->{$_}) ? ($_ => $params->{$_}) : () } qw/ user status tags watchers /
    };
    $query->{status} ||= { '$ne' => 'deleted' };

    if (delete $params->{unclaimed}) {
        die "Can't set both 'user' and 'unclaimed' at the same time" if defined $params->{user};
        $query->{user} = ''; # TODO - replace with team.$size = 0
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
    my $params = validate(@_, {
        name => { type => SCALAR },
        team => { type => ARRAYREF, optional => 1 },
        user => { type => SCALAR, optional => 1 }, # deprecated
        tags => { type => ARRAYREF, optional => 1 },
        status => { type => SCALAR, default => 'open' },
    });

    if ($params->{team}) {
        die "Can't set both team and user at the same time" if defined $params->{user};
        # temporary measure until we migrate the DB
        $params->{user} = $params->{team}[0] || '';
        delete $params->{team};
    }
    unless (defined $params->{team} or defined $params->{user}) {
        die "Either 'team' or 'user' should be set";
    }

    # validate
    # TODO - do strict validation here instead of dancer route?
    if ($params->{type}) {
        die "Unexpected quest type '$params->{type}'" unless grep { $params->{type} eq $_ } qw/ bug blog feature other /;
    }

    if ($params->{tags}) {
        die "Tags should be arrayref" unless ref($params->{tags}) eq 'ARRAY';
        $params->{tags} = [ sort @{ $params->{tags} } ];
    }

    $params->{author} = $params->{user};
    my $id = $self->collection->insert($params, { safe => 1 });

    my $quest = { %$params, _id => $id };
    $self->_prepare_quest($quest);

    db->events->add({
        object_type => 'quest',
        action => 'add',
        author => $params->{user},
        object_id => $id->to_string,
        object => $quest,
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
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

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

    if ($action eq 'close') {
        db->users->add_points($user, $self->_quest2points($quest));
    }
    elsif ($action eq 'reopen') {
        db->users->add_points($user, -$self->_quest2points($quest));
    }

    delete $quest->{_id};
    delete $quest->{ts};

    my $quest_after_update = { %$quest, %$params };
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        {
            map { $_ => $quest_after_update->{$_} }
            grep { $_ ne 'team' } # FIXME after migrating to quest.team
            keys %$quest_after_update
        },
        { safe => 1 }
    );

    # there are other actions, for example editing the quest description
    # TODO - should we split the update() method into several, more semantic methods?
    if ($action) {
        db->events->add({
            object_type => 'quest',
            action => $action,
            author => $quest_after_update->{user},
            object_id => $id,
            object => $quest_after_update,
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
        db->users->add_points($_, 1) for @team;
    }

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
    if ($quest->{status} eq 'closed') {
        db->users->add_points($quest->{user}, -1);
    }
};

sub remove {
    my $self = shift;
    my ($id, $params) = validate_pos(@_, { type => SCALAR }, { type => HASHREF });

    my $user = $params->{user};
    die 'no user' unless $user;

    # FIXME - rewrite to modifier-based atomic update!
    my $quest = $self->get($id);
    unless (grep { $_ eq $user } @{ $quest->{team} }) {
        die "access denied";
    }

    if ($quest->{status} eq 'closed') {
        db->users->add_points($user, -$self->_quest2points($quest));
    }

    delete $quest->{_id};
    $self->collection->update(
        { _id => MongoDB::OID->new(value => $id) },
        { '$set' => { status => 'deleted' } },
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

sub join {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });
    die "only non-empty users can join quests" unless length $user;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            user => '',
        },
        {
            '$set' => { user => $user },
            '$pull' => { likes => $user }, # can't like your own quest
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to join quest that's already taken";
    }
}

sub leave {
    my $self = shift;
    my ($id, $user) = validate_pos(@_, { type => SCALAR }, { type => SCALAR });
    die "only non-empty users can join quests" unless length $user;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
            user => $user,
        },
        {
            '$set' => { user => '' }
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Quest not found or unable to leave quest you don't own";
    }
}

1;
