define([
    'models/current-user',
    'models/quest',
    'views/quest/like'
], function (currentUser, QuestModel, Like) {
    describe('like:', function () {
        beforeEach(function () {
            spyOn($, 'ajax');
        });

        var proto = {
            "ts" : 1360197975,
            "status" : "open",
            "_id" : "5112f9577a8f1d370b000002",
            "team" : ["bar"],
            "name" : "q1",
            "author" : "bar"
        };

        describe('quest without likes', function () {
            var model = new QuestModel(_.extend(proto, {}));
            var view = new Like({ model: model });

            view.render();
            it("contains likes badge", function () {
                expect(view.$el).toContain('.like-button');
            });
            it("badge value is 0", function () {
                expect(view.$el.find('.like-button')).toHaveText('0');
            });
            it("is clickable", function () {
                expect(view.$el).toContain('a');
            });
        });

        describe('quest with likes', function () {
            var model = new QuestModel(_.extend(proto, { likes: ['baz', 'baz2'] }));
            var view = new Like({ model: model });

            view.render();
            it("contains likes badge", function () {
                expect(view.$el).toContain('.like-button');
                expect(view.$('.like-button')).toHaveText('2');
            });
            it("is clickable", function () {
                expect(view.$el).toContain('a');
            });
        });

        describe("current user's quest", function () {
            var model = new QuestModel(_.extend(proto, {
                likes: ['baz', 'baz2'],
                team: ['jasmine'],
                user: 'jasmine'
            }));
            var view = new Like({ model: model });

            view.render();
            it("contains likes badge", function () {
                expect(view.$el).toContain('.like-button');
            });
            it("not clickable", function () {
                expect(view.$el).not.toContain('a');
            });
        });
    });
});
