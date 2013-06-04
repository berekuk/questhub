define([
    'views/navbar'
], function (Navbar) {
    describe('navbar', function () {

        describe('when rendered', function () {
            var view = new Navbar({ realm: 'chaos' });
            view.render();

            it("is a nav", function () {
                expect(view.$el).toContain('nav');
            });
        });

        describe('active', function () {
            var view = new Navbar({ realm: 'chaos' });

            it('is empty by default', function () {
                view.render();
                expect(view.$el).not.toContain('.active');
            });

            it('is set by setActive', function () {
                view.setActive('home');
                view.render();
                expect(view.$el).toContain('.active');
            });
        });
    });
});
