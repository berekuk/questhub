package Play::DB::Images;

use Moo;

use Type::Params qw(validate);
use Types::Standard qw(Str Dict);
use Play::Types qw( Login ImageSize ImageUpic );

use Digest::MD5 qw(md5_hex);

use autodie qw(open close);

use LWP::UserAgent;

use Play::Flux;

has 'storage_dir' => (
    is => 'ro',
    isa => Str,
    default => sub { '/data/images' },
);

has 'ua' => (
    is => 'lazy',
    default => sub { LWP::UserAgent->new(timeout => 5) },
);

sub upic_by_email {
    my $self = shift;
    my ($email) = validate(\@_, Str);

    my $pic = 'http://www.gravatar.com/avatar/'.md5_hex(lc($email));
    return {
        small => "$pic?s=24",
        normal => "$pic?s=48",
    };
}

sub upic_by_twitter_login {
    my $self = shift;
    my ($login) = validate(\@_, Login);

    # TODO - fetch the right login from twitter
    my $pic = "http://api.twitter.com/1/users/profile_image?screen_name=$login";
    return {
        small => "$pic&size=mini",
        normal => "$pic&size=normal",
    };
}

sub upic_default {
    my $self = shift;
    validate(\@_);

    return {
        small => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=24",
        normal => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=48",
    };
}

sub fetch_upic {
    my $self = shift;
    my ($pic, $login) = validate(
        \@_,
        ImageUpic,
        Login
    );

    my $storage_dir = $self->storage_dir;
    for my $size (keys %$pic) {
        my $url = $pic->{$size};
        my $response = $self->ua->get($url);
        die $response->status_line unless $response->is_success;

        # TODO - check that result is the valid image
        my $file_name = "$storage_dir/pic/$login.$size";
        open my $fh, '>', "$file_name.new";
        print {$fh} $response->content;
        close $fh;
        rename "$file_name.new" => $file_name;
    }
}

sub upic_file {
    my $self = shift;
    my ($login, $size) = validate(\@_, Login, ImageSize);

    my $storage_dir = $self->storage_dir;
    my $file = "$storage_dir/pic/$login.$size";
    return $file if -e $file;
    return "/play/backend/pic/default/$size";
}

sub enqueue_fetch_upic {
    my $self = shift;
    my ($login, $upic) = validate(\@_, Login, ImageUpic);

    my $out = Play::Flux->upic;
    $out->write({ login => $login, upic => $upic });
    $out->commit;
}

1;
