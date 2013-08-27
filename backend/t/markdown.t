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

sub cpan_module :Tests {
    {
        local $Play::Markdown::REALM = 'perl';
        is
            markdown('DBIx::Class'),
            qq[<a href="http://metacpan.org/module/DBIx::Class">DBIx::Class</a>\n];
    }

    {
        local $Play::Markdown::REALM = 'blah';
        is
            markdown('DBIx::Class'),
            qq[DBIx::Class\n];
    }

    {
        local $Play::Markdown::REALM = 'perl';
        is
            markdown('cpan:Moose, `and maybe cpan:Mouse`, and cpan:Moo.'),
            qq[<a href="http://metacpan.org/module/Moose">Moose</a>, <code>and maybe cpan:Mouse</code>, and <a href="http://metacpan.org/module/Moo">Moo</a>.\n];
    }
}

__PACKAGE__->new->runtests;
