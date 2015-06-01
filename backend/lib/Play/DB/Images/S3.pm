package Play::DB::Images::S3;

use Moo;
with 'Play::DB::Images::StorageRole';

use AWS::S3;

use Play::Config qw(setting);

has 's3' => (
    is => 'lazy',
    default => sub {
        return AWS::S3->new(
            access_key_id => 's3_key',
            secret_access_key => 's3_secret',
        );
    },
);

has 'bucket_name' => (
    is => 'lazy',
    default => sub { setting('s3_images_bucket') },
);

has 'bucket' => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        return $self->s3->bucket($self->bucket_name) or die 'Bucket '.$self->bucket_name.' not found';
    },
);

sub store {
    my $self = shift;
    my ($key, $content) = validate(\@_, ImageStorageKey, Str);

    $self->bucket->add_file(key => $key, contents => \$content);
}

sub load {
    my ($self, $key) = @_;

    return ${$self->bucket->file($key)->contents};
}

sub has_key {
    my $self = shift;
    my ($key) = validate(\@_, ImageStorageKey);

    eval {
        $self->bucket->file($key);
    };
    if ($@) {
        return;
    }
    return 1;
}
