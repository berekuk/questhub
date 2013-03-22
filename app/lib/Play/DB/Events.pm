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

use Play::Mongo;

use Params::Validate qw(:all);
use Dancer qw(setting);
use Email::Simple;
use Email::Sender::Simple qw(sendmail);
use Encode qw(encode_utf8);

with 'Play::DB::Role::Common';

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
    return 1;
}

sub email {
    my $self = shift;
    my ($address, $subject, $body) = validate_pos(@_, { type => SCALAR }, { type => SCALAR }, { type => SCALAR });

    my $email = Email::Simple->create(
        header => [
            To => $address,
            From => setting('service_name').' <notification@'.setting('hostport').'>',
            Subject => encode_utf8($subject),
            'Reply-to' => 'Vyacheslav Matyukhin <me@berekuk.ru>', # TODO - take from config
            'Content-Type' => 'text/html; charset=utf-8',
        ],
        body => encode_utf8($body),
    );

    # Errors are ignored for now. (It's better than "500 Internal Error" responses)
    # TODO - introduce some kind of local asyncronous queue.
    eval {
        sendmail($email);
    };
}

# returns last 100 events
# TODO: pager
sub list {
    my $self = shift;
    my $params = validate(@_, {
        limit => { type => SCALAR, regex => qr/^\d+$/, default => 100 },
        offset => { type => SCALAR, regex => qr/^\d+$/, default => 0 },
    });

    my @events = $self->collection->query->sort({ _id => -1 })->limit($params->{limit})->skip($params->{offset})->all;
    $self->_prepare_event($_) for @events;

    return \@events;
}

1;
