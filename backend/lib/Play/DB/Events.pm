package Play::DB::Events;

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

use 5.010;

use Moo;
with 'Play::DB::Role::Common';

use Play::Mongo;
use Play::Flux;
use Play::Config qw(setting);
use Play::DB qw(db);

use Type::Params qw(validate);
use Types::Standard qw(Undef Int Str Optional HashRef Dict);

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
    die "Unknown realm '$realm'" unless grep { $_ eq $realm } @{ setting('realms') };

    my $id = $self->collection->insert($event);

    my $events_queue = Play::Flux->events;
    $events_queue->write($event);
    $events_queue->commit;

    return 1;
}

sub email {
    my $self = shift;
    my ($address, $subject, $body) = validate(\@_, Str, Str, Str);

    my $email_storage = Play::Flux->email;
    $email_storage->write([ $address, $subject, $body ]);
    $email_storage->commit;
}

sub list {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        limit => Optional[Int],
        offset => Optional[Int],
        types => Optional[Str],
        realm => Str,
    ]);
    $params //= {};
    $params->{limit} //= 100;
    $params->{offset} //= 0;

    my $search_opt = _build_search_opt($params->{types});
    $search_opt->{realm} = $params->{realm};

    my @events = $self->collection->query($search_opt)
        ->sort({ _id => -1 })
        ->limit($params->{limit})
        ->skip($params->{offset})
        ->all;

    $self->_prepare_event($_) for @events;

    {
        my @quest_events = grep { $_->{object_type} eq 'quest' } @events;
        my @quest_ids = map { $_->{object_id} } @quest_events;
        my $quests = db->quests->bulk_get(\@quest_ids);

        for my $event (@quest_events) {
            $event->{object} = $quests->{$event->{object_id}};
            $_->{deleted} = 1 unless $event->{object};
        }
    }

    @events = grep { not $_->{deleted} } @events;

    return \@events;
}

sub _build_search_opt {
    my ($types) = @_;

    return {} unless $types;

    my $filter = [];

    my @opt = split( /,/, $types );

    for (@opt) {
        my ( $action, $obj_type ) = split /-/, $_;

        push @$filter, {
            action => $action,
            object_type => $obj_type,
        };
    }

    return { '$or' => $filter };
}

1;
