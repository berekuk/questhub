define ["markdown"], (markdown) ->
    describe "markdown", ->
        it "basic markdown", ->
            expect(markdown("**susan**")).toMatch "<strong>"

        it "cpan module highlighting", ->
            expect(markdown("Dist::Zilla")).not.toMatch "<a href=\"http://metacpan.org/module/Dist::Zilla\">Dist::Zilla</a>"
            expect(markdown("Dist::Zilla", "meta")).not.toMatch "<a href=\"http://metacpan.org/module/Dist::Zilla\">Dist::Zilla</a>"
            expect(markdown("Dist::Zilla", "perl")).toMatch "<a href=\"http://metacpan.org/module/Dist::Zilla\">Dist::Zilla</a>"
            expect(markdown("Moose", "perl")).not.toMatch "<a href=\"http://metacpan.org/module/Moose\">Moose</a>"
            expect(markdown("cpan:Moose", "perl")).toMatch "<a href=\"http://metacpan.org/module/Moose\">Moose</a>"
	    expect(markdown("Task-BeLike-MELO")).toMatch "<a href=\"http://metacpan.org/release/Task-BeLike-MELO\">Task-BeLike-MELO</a>"
        it "line breaks", ->
            expect(markdown("Foo\nBar")).toMatch /Foo\s*<br>\s*Bar/



