package Play::Markdown;

use strict;
use warnings;

use Play::Config qw(setting);

use parent qw(Text::Markdown);
our @EXPORT_OK = qw(markdown);

our $REALM; # pre-set this before calling markdown
our @MENTIONS; # will be filled after markdown() call

my $obj = __PACKAGE__->new;
sub markdown {
    my ($self) = @_;

    my $result;
    if (ref $self) {
        shift;
        $result = $self->SUPER::markdown(@_);
    }
    else {
        $result = $obj->markdown(@_);
    }

    $result =~ s{^<p>}{};
    $result =~ s{</p>$}{};
    return $result;
}

sub _RunSpanGamut {
    my $self = shift;
    my ($text) = $self->SUPER::_RunSpanGamut(@_);

    if ($REALM) {
        my $hostport = setting('hostport');
        $text =~
            s{(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))}
            {
                push @MENTIONS, $2;
                qq{$1<a href="http://$hostport/$REALM/player/$2">$2</a>};
            }ge;
    }

    return $text;

}

1;
