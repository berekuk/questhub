define([
    'models/comment',
    'views/comment/normal'
], function (CommentModel, Comment) {
    describe('comments', function () {
        it('render', function () {
            var model = new CommentModel({
                "body" : "aaa",
                "ts" : 1363395653,
                "body_html" : "aaa\n",
                "quest_id" : "5143c351dd3d73910c00000e",
                "author" : "ooo"
            });
            var view = new Comment({ model: model });

            view.render();
            expect(view.$el.html()).toContain('aaa');

            // FIXME - fails because partials are not loaded via requirejs
            // expect(view.$el.html()).toContain('ooo');
        });
    });
});
