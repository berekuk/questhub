package Play::DB::Images;

use Moo;

use Type::Params qw(validate);
use Types::Standard qw( Str Dict HashRef );
use Play::Types qw( Login ImageSize ImageUpic );

use Digest::MD5 qw(md5_hex);

use autodie qw(open close rename);

use LWP::UserAgent;

use Play::Flux;
use Play::Config qw(setting);

use GD;
use Image::Resize;

my %SIZE_TO_WIDTH = (small => 24, normal => 48);

has 'storage_dir' => (
    is => 'ro',
    isa => Str,
    default => sub { setting('data_dir').'/images' },
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

sub upic_default {
    my $self = shift;
    validate(\@_);

    return {
        map {
            $_ => "http://www.gravatar.com/avatar/00000000000000000000000000000000?s=$SIZE_TO_WIDTH{$_}",
        } keys %SIZE_TO_WIDTH
    };
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

        # TODO - check that result is the valid image
        my $file_name = $self->_storage_file($login, $size);
        open my $fh, '>', "$file_name.new";
        print {$fh} $response->content;
        close $fh;
        rename "$file_name.new" => $file_name;
    }
}

sub store_upic_by_content {
    my $self = shift;
    my ($login, $content) = validate(\@_, Login, Str);

    my $gd = GD::Image->new($content);
    $gd->saveAlpha(1);
    $gd->alphaBlending(0);

    for my $size (keys %SIZE_TO_WIDTH) {
        my $width = $SIZE_TO_WIDTH{$size};
        my $resized = Image::Resize->new($gd)->resize($width, $width);
        my $resized_content = $resized->png;
        $self->_save_file(
            $self->_storage_file($login, $size),
            $resized_content
        );
    }
}

sub _save_file {
    my $self = shift;
    my ($filename, $content) = @_;

    open my $fh, '>', "$filename.new";
    print {$fh} $content;
    close $fh;
    rename "$filename.new" => $filename;
}

sub _storage_file {
    my $self = shift;
    my ($login, $size) = @_;

    return $self->storage_dir."/pic/$login.$size";
}

sub upic_file {
    my $self = shift;
    my ($login, $size) = validate(\@_, Login, ImageSize);

    my $file = $self->_storage_file($login, $size);
    return $file if -e $file;
    return "/play/backend/pic/default/$size";
}

sub is_upic_default {
    my $self = shift;
    my ($login) = validate(\@_, Login);
    my $file = $self->_storage_file($login, 'normal');
    return not -e $file;
}

sub enqueue_fetch_upic {
    my $self = shift;
    my ($login, $upic) = validate(\@_, Login, ImageUpic);

    my $out = Play::Flux->upic;
    $out->write({ login => $login, upic => $upic });
    $out->commit;
}

1;
