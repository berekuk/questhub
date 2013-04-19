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

use Moo;
with 'Play::DB::Role::Common';

use Play::Mongo;
use Play::Flux;

use Params::Validate qw(:all);

sub _prepare_event {
    my $self = shift;
    my ($event) = @_;
    $event->{ts} = $event->{_id}->get_time;
    $event->{_id} = $event->{_id}->to_string;
    return $event;
}

sub add {
    my $self = shift;
    my ($event) = validate_pos(@_, { type => HASHREF });

    my $id = $self->collection->insert($event);

    my $events_queue = Play::Flux->events;
    $events_queue->write($event);
    $events_queue->commit;

    return 1;
}

sub email {
    my $self = shift;
    my ($address, $subject, $body) = validate_pos(@_, { type => SCALAR }, { type => SCALAR }, { type => SCALAR });

    my $email_storage = Play::Flux->email;
    $email_storage->write([ $address, $subject, $body ]);
    $email_storage->commit;
}

# returns last 100 events
# TODO: pager
sub list {
    my $self = shift;
    my $params = validate(@_, {
        limit => { type => SCALAR, regex => qr/^\d+$/, default => 100 },
        offset => { type => SCALAR, regex => qr/^\d+$/, default => 0 },
        types => { type => SCALAR, regex => qr/^.+$/, optional => 1 },
    });

    my $search_opt = _build_search_opt($params->{types});

    my @events = $self->collection->query($search_opt)
        ->sort({ _id => -1 })
        ->limit($params->{limit})
        ->skip($params->{offset})
        ->all;

    $self->_prepare_event($_) for @events;

    return \@events;
}

sub _build_search_opt {
    my $types = shift;

    return {} unless $types;

    my $filter = [];

    my @opt = split( /,/, $types );

    foreach( @opt ) {
        my ( $action, $obj_type ) = split( /-/, $_ );

        push @$filter, {
            action => $action,
            object_type => $obj_type,
        };
    }

    return { '$or' => $filter };
}

1;
