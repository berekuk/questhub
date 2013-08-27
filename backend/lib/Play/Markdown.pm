package Play::Markdown;

use strict;
use warnings;

use Play::WWW;

use parent qw(Text::Markdown);
our @EXPORT_OK = qw(markdown);

use Types::Standard qw(Str);

our $REALM; # pre-set this before calling markdown
our @MENTIONS; # will be filled after markdown() call

my $obj = __PACKAGE__->new;
sub markdown {
    my $self = (ref $_[0] ? shift : undef);
    my ($original_text, @rest) = @_;
    local $REALM = $rest[0] if @rest == 1 and Str->check($rest[0]);

    @MENTIONS = ();

    my $result;
    if (ref $self) {
        $result = $self->SUPER::markdown($original_text);
    }
    else {
        $result = $obj->markdown($original_text);
    }

    if ($original_text !~ /\n/) {
        # remove surrounding <p>, but only if text is a single line
        $result =~ s{^<p>}{};
        $result =~ s{</p>$}{};
    }
    return $result;
}

sub _RunSpanGamut {
    my $self = shift;
    my ($text) = $self->SUPER::_RunSpanGamut(@_);

    # expand mentions
    {
        $text =~
            s{(^|[^\w])@(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))}
            {
                push @MENTIONS, $2;
                qq[$1<a href="] . Play::WWW->player_url($2) . qq[">$2</a>];
            }ge;
    }

    # expand CPAN module names
    {
        if ($REALM and $REALM eq 'perl') {
            $text =~
                s{\b(\w+(?:::\w+)+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))}
                 {<a href=\"http://metacpan.org/module/$1\">$1</a>}g;
            $text =~
                s{\bcpan:(\w+)(?![^<>]*>)(?![^<>]*(?:>|<\/a>|<\/code>))}
                 {<a href=\"http://metacpan.org/module/$1\">$1</a>}g;
        }
    }

    return $text;

}

1;
