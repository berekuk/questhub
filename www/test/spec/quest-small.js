define([
    'views/quest/small',
    'models/quest',
    'jasmine-jquery'
], function (QuestSmall, QuestModel) {
    describe('quest-small', function () {
        var model = new QuestModel({
            "ts" : 1360197975,
            "status" : "closed",
            "_id" : "5112f9577a8f1d370b000002",
            "team" : ["berekuk"],
            "name" : "Fix Google Analytics code on play-perl.org",
            "author" : "mmcleric",
            "tags" : ["bug"],
            "likes": ["bessarabov", "kappa"]
        });

        describe('render', function () {
            var view = new QuestSmall({ model: model });
            view.render();

            it('small quest is a table row', function () {
                expect(view.$el).toBe('tr');
            });

            it('quest status badge', function () {
                expect(view.$el.find('.pull-right .label-false')).toHaveText('complete');
            });

            it('quest tag badge', function () {
                expect(view.$el.find('.pull-right .label-inverse')).toHaveText('bug');
            });
        });

        describe('showAuthor', function () {

            it('no team by default', function () {
                var view = new QuestSmall({ model: model });
                view.render();
                expect(view.$el.html()).not.toContain('berekuk');
            });

            it('show team when showAuthor is on', function () {
                var view = new QuestSmall({ model: model, showAuthor: true });
                view.render();
                expect(view.$el.html()).toContain('berekuk');
            });

        });

        // TODO - test mouseover, will require the mocking of currentUser

    });
});
