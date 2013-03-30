define([
    'views/quest/big',
    'models/quest',
    'jasmine-jquery'
], function (QuestBig, QuestModel) {
    describe('quest-big', function () {

        describe('render', function () {
            describe('non-empty team', function () {
                var model = new QuestModel({
                    "ts" : 1360197975,
                    "status" : "closed",
                    "_id" : "5112f9577a8f1d370b000002",
                    "team" : ["badger"],
                    "name" : "Badger Badger",
                    "author" : "jonti",
                    "tags" : ["feature"],
                    "likes": ["mushroom", "snake"]
                });

                var view = new QuestBig({ model: model });
                view.render();

                it('"is on a quest"', function () {
                    expect(view.$el.html()).toContain('is on a quest');
                    expect(view.$el.html()).toContain('badger');
                });

                it('not "suggests a quest"', function () {
                    expect(view.$el.html()).not.toContain('suggests a quest');
                });
            });

            describe('empty team', function () {
                var model = new QuestModel({
                    "ts" : 1360197975,
                    "status" : "closed",
                    "_id" : "5112f9577a8f1d370b000002",
                    "team" : [],
                    "name" : "Badger Badger",
                    "author" : "jonti",
                    "tags" : ["feature"],
                    "likes": ["mushroom", "snake"]
                });

                var view = new QuestBig({ model: model });
                view.render();

                it('not "is on a quest"', function () {
                    expect(view.$el.html()).not.toContain('is on a quest');
                });

                it('"suggests a quest"', function () {
                    expect(view.$el.html()).toContain('suggests a quest');
                });
            });

        });

    });
});
