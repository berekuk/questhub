package Play::DB::Feeds;

use 5.010;
use Moo;

use Type::Params qw(validate);
use Types::Standard qw(Undef Int Str Optional HashRef ArrayRef Dict);
use Play::Types qw(Login Realm);

use Play::DB qw(db);

sub _feed_for_query {
    my $self = shift;
    my ($params) = validate(\@_, Undef|Dict[
        for => Str,
    ]);

    my $query = {};
    {
        my $user = db->users->get_by_login($params->{for}) or die "User '$params->{for}' not found";

        my @subqueries;
        if ($user->{fr}) {
            push @subqueries, { realm => { '$in' => $user->{fr} } };
        }
        $user->{fu} ||= [];
        push @{ $user->{fu} }, $user->{login};
        push @subqueries, { team => { '$in' => $user->{fu} } };
        push @subqueries, { author => { '$in' => $user->{fu} } };
        push @subqueries, { watchers => $user->{login} };

        if (@subqueries) {
            $query->{'$or'} = \@subqueries;
        }
        else {
            $query->{no_such_field} = 'no_such_value';
        }
        $query->{status} = { '$ne' => 'deleted' };
    }
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
        for => Optional[Str],
        realm => Optional[Realm],
    ]);
    $params->{limit} //= 30;
    $params->{sort} = 'bump';

    my $query;
    $query = $self->_feed_for_query({ for => $params->{for} }) if defined $params->{for};
    $query = $self->_feed_realm_query({ realm => $params->{realm} }) if defined $params->{realm};
    die "no for and no realm" unless $query;
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
