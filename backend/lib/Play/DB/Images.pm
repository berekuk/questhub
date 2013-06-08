package Play::DB::Images;

use Moo;

use Type::Params qw(validate);
use Types::Standard qw(Str);

use Digest::MD5 qw(md5_hex);

has 'storage_dir' => (
    is => 'ro',
    isa => Str,
    default => sub { '/data/images' },
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
    my ($login) = validate(\@_, Str);

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

1;
