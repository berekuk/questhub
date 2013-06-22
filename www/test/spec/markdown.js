define([
    'markdown'
], function (markdown) {
    describe('markdown', function () {
        it('basic markdown', function () {
            expect(markdown('**susan**')).toMatch('<strong>');
        });

        it('cpan module highlighting', function () {
            expect(markdown('Dist::Zilla')).not.toMatch('<a href="http://metacpan.org/module/Dist::Zilla">Dist::Zilla</a>');
            expect(markdown('Dist::Zilla', 'meta')).not.toMatch('<a href="http://metacpan.org/module/Dist::Zilla">Dist::Zilla</a>');
            expect(markdown('Dist::Zilla', 'perl')).toMatch('<a href="http://metacpan.org/module/Dist::Zilla">Dist::Zilla</a>');
            expect(markdown('Moose', 'perl')).not.toMatch('<a href="http://metacpan.org/module/Moose">Moose</a>');
            expect(markdown('cpan:Moose', 'perl')).toMatch('<a href="http://metacpan.org/module/Moose">Moose</a>');
        });

        it('line breaks', function () {
            expect(markdown('Foo\nBar')).toMatch(/Foo\s*<br>\s*Bar/);
        });

    });
});
