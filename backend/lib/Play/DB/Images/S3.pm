package Play::DB::Images::S3;

use Moo;
use Type::Params qw(validate);

use Types::Standard qw( Str );
use Play::Types qw( ImageStorageKey );
with 'Play::DB::Images::StorageRole';

use Play::Config qw(setting);
use AWS::S3;

has 's3' => (
    is => 'lazy',
    default => sub {
        return AWS::S3->new(
            access_key_id => setting('aws')->{access_key_id},
            secret_access_key => setting('aws')->{secret_access_key},
        );
    },
);

has 'bucket_name' => (
    is => 'lazy',
    default => sub { setting('s3_bucket') },
);

has 'bucket' => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        my $bucket = $self->s3->bucket($self->bucket_name);
        die 'Bucket '.$self->bucket_name.' not found' unless $bucket;
        return $bucket;
    },
);

sub s3_key {
    my $self = shift;
    my ($key) = validate(\@_, ImageStorageKey);
    return "upic/$key";
}

sub store {
    my $self = shift;
    my ($key, $content) = validate(\@_, ImageStorageKey, Str);

    $self->bucket->add_file(
        key => $self->s3_key($key),
        contents => \$content,
    );
}

sub load {
    my ($self, $key) = @_;

    return ${
        $self->bucket->file(
            $self->s3_key($key)
        )->contents
    };
}

sub has_key {
    my $self = shift;
    my ($key) = validate(\@_, ImageStorageKey);

    return unless $self->bucket->file(
        $self->s3_key($key)
    );
    return 1;
}

1;
