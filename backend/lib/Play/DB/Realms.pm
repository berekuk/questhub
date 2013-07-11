package Play::DB::Realms;

use 5.010;
use Moo;

use Type::Params qw(validate);
use Play::Config qw(setting);
use Types::Standard qw(Str);

sub list {
    my $self = shift;
    validate(\@_);

    state $_list =
    setting('test')
    ? [
        { id => 'europe', name => 'Europe', description => 'europe-europe', pic => 'europe.jpg' },
        { id => 'asia', name => 'Asia', description => 'asia-asia', pic => 'asia.jpg' },
    ]
    : [
        {
            id => 'perl',
            name => 'Play Perl',
            description => 'Everything about Perl: Perl 5 and Perl 6, uploading CPAN modules and reporting bugs, writing blog posts and recording podcasts, giving Perl talks and organizing YAPC events.',
            pic => '/i/perl.png',
            keepers => ['yanick', 'tobyink', 'neilb'],
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
    my ($id) = validate(\@_, Str);

    my ($realm) = grep { $id eq $_->{id} } @{ $self->list };
    unless ($realm) {
        die "Unknown realm '$id'";
    }
    return $realm;
}

sub validate_name {
    my $self = shift;
    my ($id) = validate(\@_, Str);

    $self->get($id);
    return;
}

1;
