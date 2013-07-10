package Play::DB::Events;

=head1 FORMAT

Events can be of different types and contain different loosely-typed fields.

See C<API.md> for the description of its structure.

=cut

use 5.010;

use Moo;
with 'Play::DB::Role::Common';

use Log::Any qw($log);

use Play::Mongo;
use Play::Flux;
use Play::Config qw(setting);
use Play::DB qw(db);

use Type::Params qw(validate);
use Types::Standard qw(Undef Int Str Optional HashRef ArrayRef Dict);
use Play::Types qw(Login);

sub _prepare_event {
    my $self = shift;
    my ($event) = @_;
    $event->{ts} = $event->{_id}->get_time;
    $event->{_id} = $event->{_id}->to_string;
    return $event;
}

sub add {
    my $self = shift;
    my ($event) = validate(\@_, HashRef);

    my $realm = $event->{realm};
    die "'realm' is not defined" unless $realm;
    db->realms->validate_name($realm);

    my $id = $self->collection->insert($event);

    my $events_queue = Play::Flux->events;
    $events_queue->write($event);
    $events_queue->commit;

    return 1;
}

sub email {
    my $self = shift;
    my ($item) = validate(\@_, Dict[
        address => Str,
        subject => Str,
        body => Str,
        notify_field => Optional[Str],
        login => Optional[Login],
    ]);

    my $email_storage = Play::Flux->email;
    $email_storage->write($item);
    $email_storage->commit;
}

sub expand_events {
    my $self = shift;
    my ($events) = validate(\@_, ArrayRef);

    my @events = @$events;

    # fetch quests
    {
        my @quest_events = grep {
            defined $_->{quest_id}
        } @events;
        my @quest_ids = map { $_->{quest_id} } @quest_events;

        if (@quest_ids) {
            my $quests = db->quests->bulk_get(\@quest_ids);

            for my $event (@quest_events) {
                $event->{quest} = $quests->{$event->{quest_id}};
                $event->{deleted} = 1 unless $event->{quest};
            }
        }
    }

    # fetch comments
    {
        my @comment_events = grep {
            defined $_->{comment_id}
        } @events;
        my @comment_ids = map { $_->{comment_id} } @comment_events;

        if (@comment_ids) {
            my $comments = db->comments->bulk_get(\@comment_ids);

            for my $event (@comment_events) {
                $event->{comment} = $comments->{$event->{comment_id}};
                $event->{deleted} = 1 unless $event->{comment};
            }
        }
    }

    # fetch stencils
    {
        my @stencil_events = grep {
            defined $_->{stencil_id}
        } @events;
        my @stencil_ids = map { $_->{stencil_id} } @stencil_events;

        if (@stencil_ids) {
            my $stencils = db->stencils->bulk_get(\@stencil_ids);

            for my $event (@stencil_events) {
                $event->{stencil} = $stencils->{$event->{stencil_id}};
            }
        }
    }

    @events = grep { not $_->{deleted} } @events;

    return \@events;
}

sub list {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        limit => Optional[Int],
        offset => Optional[Int],
        realm => Optional[Str],
        for => Optional[Str],
        author => Optional[Login],
    ]);
    $params //= {};
    $params->{limit} //= 100;
    $params->{offset} //= 0;

    my $search_opt = {};

    if (defined $params->{realm}) {
        $search_opt->{realm} = $params->{realm};
    }
    elsif (defined $params->{for}) {
        my $user = db->users->get_by_login($params->{for}) or die "User '$params->{for}' not found";

        my @subqueries;
        if ($user->{fr}) {
            push @subqueries, { realm => { '$in' => $user->{fr} } };
        }
        $user->{fu} ||= [];
        push @{ $user->{fu} }, $user->{login};
        push @subqueries, { author => { '$in' => $user->{fu} } };

        if (@subqueries) {
            $search_opt->{'$or'} = \@subqueries
        }
        else {
            $search_opt->{no_such_field} = 'no_such_value';
        }
    }

    $search_opt->{author} = $params->{author} if defined $params->{author};

    my ($limit, $offset) = ($params->{limit}, $params->{offset});

    my $got_more = 1;
    my @result;
    my $trials = 0;

    # expand_events can filter out some events, but we need to return *exactly* $limit queries
    # so we're increasing $offset and fetching more if necessary
    while (@result < $limit and $got_more) {
        my @events = $self->collection->query($search_opt)
            ->sort({ _id => -1 })
            ->limit($limit - scalar @result) # TODO - fetch more than necessary to reduce the chance of follow-up queries
            ->skip($offset)
            ->all;

        $got_more = 0 if @events < $limit;

        $self->_prepare_event($_) for @events;
        $offset += @events;
        @events = @{ $self->expand_events(\@events) };

        push @result, @events; # TODO - filter possible duplicates?

        $trials++;
        if ($trials > 10) {
            $log->warn('events->list tried to refetch events too many times');
            last;
        }
    }

    return \@result;
}

1;
