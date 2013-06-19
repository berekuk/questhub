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
      name => 'quest name',
      description => 'markdown text',
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

=head1 METHODS

=over

=cut

use 5.010;
use utf8;

use Moo;

use Type::Params qw( compile validate );
use Types::Standard qw( Undef Bool Int Str Optional Dict ArrayRef HashRef );
use Play::Types qw( Id Login );

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

=item B<get($id)>

=cut
sub get {
    my $self = shift;
    state $check = compile(Id);
    my ($id) = $check->(@_);

    my $quest = $self->collection->find_one({
        _id => MongoDB::OID->new(value => $id)
    });
    die "quest $id not found" unless $quest;
    die "quest $id is deleted" if $quest->{status} eq 'deleted';
    $self->_prepare_quest($quest);
    return $quest;
}

=item B<bulk_get(\@ids)>

=cut
sub bulk_get {
    my $self = shift;
    state $check = compile(ArrayRef[Id]);
    my ($ids) = $check->(@_);

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

=item B<list($filter_hashref)>

=cut
sub list {
    my $self = shift;
    state $check = compile(Undef|Dict[
        # find() filters
        user => Optional[Login],
        realm => Optional[Str],
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
    my ($params) = $check->(@_);
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

sub _update_user_realms {
    my $self = shift;
    state $check = compile(HashRef);
    my ($quest) = $check->(@_);

    for my $team_member (@{ $quest->{team} }) {
        my $user = db->users->get_by_login($team_member) or die "User '$team_member' not found";
        unless (grep { $_ eq $quest->{realm} } @{ $user->{realms} }) {
            db->users->join_realm($team_member, $quest->{realm});
        }
    }
}

=item B<add($quest_parameters)>

=cut
sub add {
    my $self = shift;
    state $check = compile(Dict[
        realm => Str,
        name => Str,
        description => Optional[Str],
        user => Optional[Login],
        team => Optional[ArrayRef[Login]],
        tags => Optional[ArrayRef[Str]],
        status => Optional[Str],
    ]);
    my ($params) = $check->(@_);
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

    $self->_update_user_realms($params);

    if ($params->{tags}) {
        die "Tags should be arrayref" unless ref($params->{tags}) eq 'ARRAY';
        $params->{tags} = [ sort @{ $params->{tags} } ];
    }

    $params->{author} = $params->{team}[0];
    my $id = $self->collection->insert($params, { safe => 1 });

    my $quest = { %$params, _id => $id };
    $self->_prepare_quest($quest);

    db->events->add({
        type => 'add-quest',
        author => $params->{author},
        quest_id => $id->to_string,
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

=item B<update($id, $fields_to_update_hashref)>

=cut
sub update {
    my $self = shift;
    state $check = compile(Id, HashRef);
    my ($id, $params) = $check->(@_);

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
            type => "$action-quest",
            author => $user,
            quest_id => $id,
            realm => $quest->{realm}
        });
    }

    return $id;
}

sub _set_status {
    my $self = shift;
    state $check = compile(Dict[
        id => Id,
        user => Login,
        new_status => Str,
        old_status => Str,
        event_type => Optional[Str],
        comment_type => Optional[Str],
        points => Optional[Int], # possible values: 1, -1
        clear_invitees => Optional[Bool],
    ]);
    my ($params) = $check->(@_);

    my $quest = $self->get($params->{id});
    unless (grep { $_ eq $params->{user} } @{$quest->{team}}) {
        die "access denied";
    }

    if ($quest->{status} ne $params->{old_status}) {
        die "Expected quest with status '$params->{old_status}', $params->{id} has status '$quest->{status}'";
    }

    if ($params->{points}) {
        my $points = $self->_quest2points($quest);
        $points = -$points if $params->{points} == -1;
        db->users->add_points($_, $points, $quest->{realm}) for @{$quest->{team}};
    }

    $self->collection->update(
        { _id => MongoDB::OID->new(value => $params->{id}) },
        {
            '$set' => { status => $params->{new_status} },
            ($params->{clear_invitees} ? ('$unset' => { 'invitee' => '' }) : ()),
        },
        { safe => 1 }
    );

    if ($params->{event_type}) {
        db->events->add({
            type => $params->{event_type},
            author => $params->{user},
            quest_id => $params->{id},
            realm => $quest->{realm}
        });
    }

    if ($params->{comment_type}) {
        db->comments->add({
            type => $params->{comment_type},
            author => $params->{user},
            quest_id => $params->{id},
        });
    }
    return;
}

=item B<close($id, $user)>

=cut
sub close {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

    $self->_set_status({
        id => $id,
        user => $user,
        old_status => 'open',
        new_status => 'closed',
        event_type => 'close-quest',
#        comment_type => 'close',
        points => 1,
        clear_invitees => 1,
    });
}

=item B<reopen($id, $user)>

=cut
sub reopen {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

    $self->_set_status({
        id => $id,
        user => $user,
        old_status => 'closed',
        new_status => 'open',
        event_type => 'reopen-quest',
#        comment_type => 'reopen',
        points => -1,
    });
}

=item B<abandon($id, $user)>

=cut
sub abandon {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

    $self->_set_status({
        id => $id,
        user => $user,
        old_status => 'open',
        new_status => 'abandoned',
        event_type => 'abandon-quest',
#        comment_type => 'abandon',
        clear_invitees => 1,
    });
}

=item B<resurrect($id, $user)>

=cut
sub resurrect {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

    $self->_set_status({
        id => $id,
        user => $user,
        old_status => 'abandoned',
        new_status => 'open',
        event_type => 'resurrect-quest',
#        comment_type => "resurrect",
    });
}

=item B<like(...), unlike(...)>

(Implemented by PushPull role, with some method modifiers)

=cut
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
    # FIXME - send to everyone, not just the first team member
    if (my $email = db->users->get_email($team[0], 'notify_likes')) {
        my $email_body = qq[
            <p>
            <a href="http://].setting('hostport').qq[/player/$user">$user</a> likes your quest <a href="http://].setting('hostport').qq[/quest/$quest->{_id}">$quest->{name}</a>.<br>
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
        db->events->email({
            address => $email,
            subject => "$user likes your quest '$quest->{name}'!",
            body => $email_body,
            notify_field => 'notify_likes',
            login => $team[0],
        });
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

=item B<remove($id, { user => $user })>

=cut
sub remove {
    my $self = shift;
    state $check = compile(Id, Dict[ user => Login ]);
    my ($id, $params) = $check->(@_);

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

=item B<invite($id, $user, $actor)>

=cut
sub invite {
    my $self = shift;
    state $check = compile(Id, Login, Login);
    my ($id, $user, $actor) = $check->(@_);

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
        type => 'invite-quest',
        author => $actor,
        quest_id => $id,
        invitee => $user,
        realm => $quest->{realm}
    });

#    db->comments->add({
#        quest_id => $id,
#        author => $actor,
#        type => 'invite',
#        invitee => $user,
#    });

    return;
}

=item B<uninvite($id, $user, $actor)>

=cut
sub uninvite {
    my $self = shift;
    state $check = compile(Id, Login, Login);
    my ($id, $user, $actor) = $check->(@_);

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

=item B<join($id, $user)>

=cut
sub join {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

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

    db->comments->add({
        type => 'join',
        author => $user,
        quest_id => $id,
    });
}

=item B<leave($id, $user)>

=cut
sub leave {
    my $self = shift;
    state $check = compile(Id, Login);
    my ($id, $user) = $check->(@_);

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

    db->comments->add({
        type => 'leave',
        author => $user,
        quest_id => $id,
    });
}

=item B<move_to_realm($id, $realm, $user)>

=cut
sub move_to_realm {
    my $self = shift;
    state $check = compile(Id, Str, Login);
    my ($id, $realm, $user) = $check->(@_);

    my $quest = $self->get($id);
    my $old_realm = $quest->{realm};
    if ($old_realm eq $realm) {
        die "Quest $id is already in realm $realm";
    }

    unless (grep { $_ eq $user } @{ $quest->{team} }) {
        die "Access denied to user $user to move the $id quest";
    }
    $quest->{realm} = $realm;

    my $result = $self->collection->update(
        {
            _id => MongoDB::OID->new(value => $id),
        },
        {
            '$set' => { realm => $realm }
        },
        { safe => 1 }
    );
    my $updated = $result->{n};
    unless ($updated) {
        die "Can't move quest - race condition?";
    }

    if ($quest->{status} eq 'closed') {
        db->users->add_points($_, -$self->_quest2points($quest), $old_realm) for @{$quest->{team}};
        db->users->add_points($_, $self->_quest2points($quest), $realm) for @{$quest->{team}};
    }

    $self->_update_user_realms($quest);
}

1;
