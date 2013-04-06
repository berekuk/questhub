define([
    'views/quest/big',
    'models/quest',
    'jasmine-jquery'
], function (QuestBig, QuestModel) {
    describe('quest-big', function () {

        beforeEach(function () {
            spyOn($, 'ajax');
        });

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

        describe('edit', function () {

            var createView = function () {
                model = new QuestModel({
                    "ts" : 1360197975,
                    "status" : "closed",
                    "_id" : "5112f9577a8f1d370b000002",
                    "team" : ["badger"],
                    "name" : "Badger Badger",
                    "author" : "jonti",
                    "tags" : ["feature"],
                    "likes": ["mushroom", "snake"]
                });

                view = new QuestBig({ model: model });
                view.render();
                return view;
                console.log(view.$el.find('h2').html());
            };

            describe('before edit is clicked', function () {
                var view = createView();

                it('title is visible', function () {
                    expect(view.$el.find('h2 .quest-title')).not.toHaveCss({ display: 'none' });
                });

                it('input is hidden', function () {
                    expect(view.$el.find('h2 input')).toHaveCss({ display: 'none' });
                });
            });

            describe('after edit is clicked', function () {
                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                });

                it('title is hidden', function () {
                    expect(view.$el.find('h2 .quest-title')).toHaveCss({ display: 'none' });
                });

                it('input is visible', function () {
                    expect(view.$el.find('h2 input')).not.toHaveCss({ display: 'none' });
                });
            });

            describe('after title is edited', function () {

                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                    spyOn(view.model, 'save');

                    view.$('.quest-edit').val('Mushroom! Mushroom!');

                    var e = $.Event('keyup');
                    e.which = 13; // enter
                    view.$('.quest-edit').trigger(e);
                });

                it('title is hidden', function () {
                    expect(view.model.save).toHaveBeenCalledWith({ 'name': 'Mushroom! Mushroom!', tags: ['feature'] });
                });
            });
        });

    });
});
