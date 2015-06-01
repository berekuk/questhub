package Play::DB::Images;

use Moo;

use Type::Params qw(validate);
use Types::Standard qw( Str HashRef );
use Play::Types qw( Login ImageSize ImageUpic );

use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use GD;
use Image::Resize;
use autodie qw( open close );

use Play::Flux;
use Play::DB::Images::Local;


my %SIZE_TO_WIDTH = (small => 24, normal => 48);

has 'local_storage' => (
    is => 'lazy',
    default => sub {
        return Play::DB::Images::Local->new;
    },
);

has 'ua' => (
    is => 'lazy',
    default => sub {
        my $ua = LWP::UserAgent->new(timeout => 5);
        $ua->protocols_allowed([qw/ http https /]);
        return $ua;
    },
);

sub upic_by_email {
    my $self = shift;
    my ($email) = validate(\@_, Str);

    my $pic = 'http://www.gravatar.com/avatar/'.md5_hex(lc($email));
    return {
        map {
            $_ => "$pic?s=$SIZE_TO_WIDTH{$_}&d=404"
        } keys %SIZE_TO_WIDTH
    };
}

sub upic_default {
    my $self = shift;
    validate(\@_);
    return {
        map {
            $_ => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=$SIZE_TO_WIDTH{$_}",
        } keys %SIZE_TO_WIDTH
    };
}

sub upic_by_twitter_data {
    my $self = shift;
    my ($twitter_data) = validate(\@_, HashRef);

    my $url = $twitter_data->{profile_image_url};
    my $small_url = $url;
    $small_url =~ s{(normal)(\.\w+)$}{mini$2} or $small_url =~ s{normal$}{mini} or die "Unexpected twitter url '$url'";
    return {
        small => $small_url,
        normal => $url,
    };
}

sub key {
    my $self = shift;
    my ($login, $size) = validate(\@_, Login, ImageSize);
    return "$login.$size";
}

sub fetch_upic {
    my $self = shift;
    my ($pic, $login) = validate(
        \@_,
        ImageUpic,
        Login
    );

    for my $size (keys %$pic) {
        my $url = $pic->{$size};
        my $response = $self->ua->get($url);
        die $response->status_line unless $response->is_success;

        my $content = $response->content;

        # TODO - check that result is the valid image
        $self->local_storage->store(
            $self->key($login, $size),
            $content
        );
    }
}

sub store {
    my $self = shift;
    my ($login, $content) = validate(\@_, Login, Str);

    my $gd = GD::Image->new($content);
    $gd->saveAlpha(1);
    $gd->alphaBlending(0);

    for my $size (keys %SIZE_TO_WIDTH) {
        my $width = $SIZE_TO_WIDTH{$size};
        my $resized = Image::Resize->new($gd)->resize($width, $width);
        my $resized_content = $resized->png;

        $self->local_storage->store(
            $self->key($login, $size),
            $resized_content
        );
    }
}

sub _load_default {
    my $self = shift;
    my ($size) = validate(\@_, ImageSize);
    open my $fh, '<', "/play/backend/pic/default/$size";
    local $/ = undef;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub has_key {
    my $self = shift;
    my ($login, $size) = validate(\@_, Login, ImageSize);

    my $key = $self->key($login, $size);
    return $self->local_storage->has_key($key);
}

sub load {
    my $self = shift;
    my ($login, $size) = validate(\@_, Login, ImageSize);

    my $key = $self->key($login, $size);
    if ($self->local_storage->has_key($key)) {
        return $self->local_storage->load($key);
    }
    return $self->_load_default($size);
}

sub enqueue_fetch_upic {
    my $self = shift;
    my ($login, $upic) = validate(\@_, Login, ImageUpic);

    my $out = Play::Flux->upic;
    $out->write({ login => $login, upic => $upic });
    $out->commit;
}

1;
