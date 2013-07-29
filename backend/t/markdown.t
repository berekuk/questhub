use lib 'lib';
use Play::Test;
use parent qw(Test::Class);

use Play::Markdown qw(markdown);

sub basic :Tests {
    is markdown("**blah**"), "<strong>blah</strong>\n";
    is markdown("Line 1\n\nLine 2"), "<p>Line 1</p>\n\n<p>Line 2</p>\n";
}

sub mentions :Tests {
    is
        markdown('@blah, hello'),
        qq[<a href="http://localhost:3000/player/blah">blah</a>, hello\n];

    cmp_deeply \@Play::Markdown::MENTIONS, ['blah'];

    # let's go again - make sure that @MENTIONS is cleaned
    markdown('@blah2, @blah3, hello');
    cmp_deeply \@Play::Markdown::MENTIONS, ['blah2', 'blah3'];
}

__PACKAGE__->new->runtests;
