define([
    'markdown'
], function (markdown) {
    describe('markdown', function () {
        it('basic markdown', function () {
            expect(markdown('**susan**')).toMatch('<strong>');
        });

        it('cpan module highlighting', function () {
            expect(markdown('Dist::Zilla')).toMatch('<a href="http://metacpan.org/module/Dist::Zilla">Dist::Zilla</a>');
            expect(markdown('Moose')).not.toMatch('<a href="http://metacpan.org/module/Moose">Moose</a>');
            expect(markdown('cpan:Moose')).toMatch('<a href="http://metacpan.org/module/Moose">Moose</a>');
        });
    });
});
