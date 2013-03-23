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
            "user" : "berekuk",
            "name" : "Fix Google Analytics code on play-perl.org",
            "author" : "berekuk",
            "type" : "bug",
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

            it('quest type badge', function () {
                expect(view.$el.find('.pull-right .label-inverse')).toHaveText('bug');
            });
        });

        // TODO - test mouseover, will require the mocking of currentUser

    });
});
