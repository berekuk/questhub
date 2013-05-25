package Play::Markdown;

use strict;
use warnings;

use Play::Config qw(setting);

use parent qw(Text::Markdown);
our @EXPORT_OK = qw(markdown);

our $REALM; # pre-set this before calling markdown

my $obj = __PACKAGE__->new;
sub markdown {
    my ($self) = @_;
    if (ref $self) {
        shift;
        return $self->SUPER::markdown(@_);
    }
    else {
        return $obj->markdown(@_);
    }
}

sub _RunSpanGamut {
    my $self = shift;
    my ($text) = $self->SUPER::_RunSpanGamut(@_);

    if ($REALM) {
        my $hostport = setting('hostport');
        $text =~
            s{(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))}
            {$1<a href="http://$hostport/$REALM/player/$2">$2</a>}g;
    }

    return $text;

}

1;
