package Play::DB::Realms;

use 5.010;
use Moo;
with 'Play::DB::Role::Common';

use Type::Params qw(compile);
use Play::Config qw(setting);
use Play::DB qw(db);

use Types::Standard qw( Str StrMatch Dict ArrayRef Optional );
use Play::Types qw( Login Realm RealmName );

sub _prepare {
    my $self = shift;
    my ($realm) = @_;
    delete $realm->{_id};
    $realm->{keepers} ||= [];
    return $realm;
}

sub list {
    my $self = shift;
    state $check = compile();
    $check->(@_);

    my @realms = $self->collection->find()->all; # TODO - sort
    $self->_prepare($_) for @realms;
    return \@realms;
}

sub add {
    my $self = shift;
    state $check = compile(Dict[
        id => Realm,
        name => StrMatch[ qr/^.{1,16}$/ ],
        description => Str,
        pic => Str,
        keepers => Optional[ArrayRef[Login]],
    ]);
    my ($params) = $check->(@_);

    my $id = $self->collection->insert($params, { safe => 1 });
    return "$id";
}

sub get {
    my $self = shift;
    state $check = compile(Realm);
    my ($id) = $check->(@_);

    my $realm = $self->collection->find_one({
        id => $id
    });
    die "Unknown realm '$id'" unless $realm;
    $self->_prepare($realm);
    return $realm;
}

sub update {
    my $self = shift;
    state $check = compile(Realm, Dict[
        user => Login,
        name => Optional[RealmName],
        description => Optional[Str],
    ]);
    my ($id, $params) = $check->(@_);

    my $user = delete $params->{user};

    my $realm = $self->get($id);
    unless (grep { $_ eq $user } @{$realm->{keepers}}) {
        die "access denied";
    }

    my $realm_after_update = { %$realm, %$params };
    $self->collection->update(
        { id => $id },
        $realm_after_update,
        { safe => 1 }
    );

    return $id;
}

# TODO - call this regularly
sub update_stat {
    my $self = shift;
    state $check = compile(Realm);
    my ($id) = $check->(@_);

    my $users = db->users->list({ realm => $id });
    $self->collection->update(
        { id => $id },
        { '$set' => { 'stat.users' => scalar @$users } },
        { safe => 1 }
    );

    return;
}

sub add_user {
    my $self = shift;
    my $check = compile(Login, Realm);
    my ($login, $id) = $check->(@_);

    my $result = $self->collection->update(
        { id => $id },
        { '$inc' => { 'stat.users' => 1 } },
        { safe => 1 }
    );

    my $updated = $result->{n};
    unless ($updated) {
        die "Realm $id not found";
    }
    return;
}

sub validate_name {
    my $self = shift;
    state $check = compile(Realm);
    my ($id) = $check->(@_);

    $self->get($id);
    return;
}

sub is_keeper {
    my $self = shift;
    state $check = compile(Realm, Login);
    my ($id, $login) = $check->(@_);

    my $realm = $self->get($id);

    return undef unless $realm->{keepers};
    if (grep { $_ eq $login } @{ $realm->{keepers} }) {
        return 1;
    }
    return undef;
}

sub reset_to_initial {
    my $self = shift;
    state $check = compile();
    $check->(@_);

    my @realms;
    if (setting('test')) {
        @realms = (
            { id => 'europe', name => 'Europe', description => 'europe-europe', pic => 'europe.jpg', keepers => ['foo', 'foo2'] },
            { id => 'asia', name => 'Asia', description => 'asia-asia', pic => 'asia.jpg', keepers => ['bar', 'bar2'] },
        );
    }
    else {
        @realms = (
            {
                id => 'perl',
                name => 'Play Perl',
                description => 'Everything about Perl: Perl 5 and Perl 6, uploading CPAN modules and reporting bugs, writing blog posts and recording podcasts, giving Perl talks and organizing YAPC events.',
                pic => '/i/perl.png',
                keepers => ['yanick', 'tobyink', 'neilb', 'berekuk', 'szabgab'],
            },
            {
                id => 'chaos',
                name => 'Chaotic realm',
                description => qq{First rule of chaotic realm is: there are no rules. Points don't mean much here. Anything goes, from "get a driving license" to "read a book".\n\nThis realm is currently   occupied by Russians, but don't let this discourage you if you don't speak Russian. Everyone is welcome!},
                pic => '/i/chaos.png',
                keepers => ['bessarabov', 'berekuk', 'Nazer'],
            },
            {
                id => 'meta',
                name => 'Meta hub',
                description => "Questhub development center. \@berekuk is dogfooding here, mostly alone.\n\nYou can follow questhub development here and encourage me to work on new features and fix bugs."  ,
                pic => '/i/meta.png',
                keepers => ['berekuk'],
            }
        );
    }

    $self->add($_) for @realms;
}

1;
