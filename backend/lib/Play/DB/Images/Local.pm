package Play::DB::Images::Local;

use Moo;
with 'Play::DB::Images::StorageRole';

use Type::Params qw(validate);
use Types::Standard qw( Str );
use Play::Types qw( ImageStorageKey );

use Play::Config qw(setting);

use autodie qw( open rename close );

has 'storage_dir' => (
    is => 'ro',
    isa => Str,
    default => sub { setting('data_dir').'/images' },
);

sub _filename {
    my $self = shift;
    my ($key) = validate(\@_, ImageStorageKey);

    return $self->storage_dir."/pic/$key";
}

sub store {
    my $self = shift;
    my ($key, $content) = validate(\@_, ImageStorageKey, Str);

    my $filename = $self->_filename($key);
    open my $fh, '>', "$filename.new";
    print {$fh} $content;
    close $fh;
    rename "$filename.new" => $filename;
}

sub load {
    my ($self, $key) = @_;

    my $filename = $self->_filename($key);
    open my $fh, '<', $filename;
    local $/ = undef;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub has_key {
    my $self = shift;
    my ($key) = validate(\@_, ImageStorageKey);

    return -e $self->_filename($key);
}

1;
