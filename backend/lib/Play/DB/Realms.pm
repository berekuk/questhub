package Play::DB::Realms;

use 5.010;
use Moo;

use Type::Params qw(validate);
use Play::Config qw(setting);
use Types::Standard qw(Str);
use Play::Types qw(Login Realm);

sub list {
    my $self = shift;
    validate(\@_);

    state $_list =
    setting('test')
    ? [
        { id => 'europe', name => 'Europe', description => 'europe-europe', pic => 'europe.jpg', keepers => ['foo', 'foo2'] },
        { id => 'asia', name => 'Asia', description => 'asia-asia', pic => 'asia.jpg', keepers => ['bar', 'bar2'] },
    ]
    : [
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
            description => qq{First rule of chaotic realm is: there are no rules. Points don't mean much here. Anything goes, from "get a driving license" to "read a book".\n\nThis realm is currently occupied by Russians, but don't let this discourage you if you don't speak Russian. Everyone is welcome!},
            pic => '/i/chaos.png',
            keepers => ['bessarabov', 'berekuk', 'Nazer'],
        },
        {
            id => 'meta',
            name => 'Meta hub',
            description => "Questhub development center. \@berekuk is dogfooding here, mostly alone.\n\nYou can follow questhub development here and encourage me to work on new features and fix bugs.",
            pic => '/i/meta.png',
            keepers => ['berekuk'],
        },
    ];
    return $_list;
}

sub get {
    my $self = shift;
    my ($id) = validate(\@_, Realm);

    my ($realm) = grep { $id eq $_->{id} } @{ $self->list };
    unless ($realm) {
        die "Unknown realm '$id'";
    }
    return $realm;
}

sub validate_name {
    my $self = shift;
    my ($id) = validate(\@_, Realm);

    $self->get($id);
    return;
}

sub is_keeper {
    my $self = shift;
    my ($id, $login) = validate(\@_, Realm, Login);

    my $realm = $self->get($id);

    return undef unless $realm->{keepers};
    if (grep { $_ eq $login } @{ $realm->{keepers} }) {
        return 1;
    }
    return undef;
}

1;
