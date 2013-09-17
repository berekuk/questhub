package Play::DB::Feeds;

use 5.010;
use Moo;

use Type::Params qw(validate);
use Types::Standard qw(Undef Int Str Optional HashRef ArrayRef Dict);
use Play::Types qw(Login Realm NewsFeedTab);

use Play::DB qw(db);

sub _feed_for_query {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        for => Login,
        tab => NewsFeedTab,
    ]);

    my $user = db->users->get_by_login($params->{for}) or die "User '$params->{for}' not found";

    my $query = {};
    my @subqueries;

    my $add_realms = sub {
        if ($user->{fr}) {
            push @subqueries, { realm => { '$in' => $user->{fr} } };
        }
    };
    my $add_users = sub {
        $user->{fu} ||= [];
        push @{ $user->{fu} }, $user->{login};
        push @subqueries, { team => { '$in' => $user->{fu} } };
        push @subqueries, { author => { '$in' => $user->{fu} } };
    };
    my $add_watched = sub {
        push @subqueries, { watchers => $user->{login} };
    };

    if ($params->{tab} eq 'default') {
        $add_realms->();
        $add_users->();
        $add_watched->();
    }
    elsif ($params->{tab} eq 'users') {
        $add_users->();
    }
    elsif ($params->{tab} eq 'realms') {
        $add_realms->();
    }
    elsif ($params->{tab} eq 'watched') {
        $add_watched->();
    }
    elsif ($params->{tab} eq 'global') {
        # will handle this case later
    }
    else {
        die "Unknown tab '$params->{tab}'";
    }

    if (@subqueries) {
        $query->{'$or'} = \@subqueries;
    }
    elsif ($params->{tab} ne 'global') {
        $query->{no_such_field} = 'no_such_value';
    }
    $query->{status} = { '$ne' => 'deleted' };
    return $query;
}

sub _feed_realm_query {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        realm => Realm,
    ]);

    my $query = {};
    $query->{realm} = $params->{realm};
    $query->{status} = { '$ne' => 'deleted' };
    return $query;

}

sub feed {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        limit => Optional[Int],
        offset => Optional[Int],
        for => Optional[Login],
        tab => Optional[NewsFeedTab],
        realm => Optional[Realm],
    ]);
    $params->{limit} //= 30;
    $params->{tab} //= 'default';
    $params->{sort} = 'bump';

    my $query;
    if (defined $params->{for}) {
        $query = $self->_feed_for_query({
            for => $params->{for},
            tab => $params->{tab},
        });
    }
    elsif (defined $params->{realm}) {
        $query = $self->_feed_realm_query({ realm => $params->{realm} });
    }
    else {
        die "no for and no realm";
    }

    my $cursor = Play::Mongo->db->get_collection('posts')->find($query);

    $cursor = $cursor->limit($params->{limit});
    $cursor = $cursor->skip($params->{offset}) if $params->{offset};
    $cursor = $cursor->sort({ bump => -1 });
    my @posts = $cursor->all;

    $_ = db->quests->prepare($_) for grep { $_->{entity} eq 'quest' } @posts;
    $_ = db->stencils->prepare($_) for grep { $_->{entity} eq 'stencil' } @posts;
    db->stencils->_fill_quests($_) for grep { $_->{entity} eq 'stencil' } @posts;

    my @items = map {
        { post => $_ }
    } @posts;

    @items = sort {
        ($b->{post}{bump} || 0)
        <=>
        ($a->{post}{bump} || 0)
    } @items;

    for my $item (@items) {
        $item->{comments} = db->comments->list($item->{post}{entity}, $item->{post}{_id}); # TODO - slow, optimize
    }
    return \@items;
}

1;
