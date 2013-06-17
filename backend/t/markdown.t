use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::Markdown qw(markdown);

sub basic :Tests {
    is markdown("**blah**"), "<strong>blah</strong>\n";
    is markdown("Line 1\n\nLine 2"), "<p>Line 1</p>\n\n<p>Line 2</p>\n";
}

__PACKAGE__->new->runtests;
