define([
    'views/quest/big',
    'models/quest',
    'jasmine-jquery'
], function (QuestBig, QuestModel) {
    describe('quest-big', function () {

        beforeEach(function () {
            spyOn($, 'ajax');
        });

        describe('render: ', function () {
            describe('non-empty team', function () {
                var model = new QuestModel({
                    "ts" : 1360197975,
                    "status" : "closed",
                    "_id" : "5112f9577a8f1d370b000002",
                    "team" : ["badger"],
                    "name" : "Badger Badger",
                    "author" : "jonti",
                    "tags" : ["feature"],
                    "likes": ["mushroom", "snake"],
                    "realm": "chaos"
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
                    "likes": ["mushroom", "snake"],
                    "realm": "chaos"
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

        describe('edit: ', function () {

            var createView = function () {
                model = new QuestModel({
                    "ts" : 1360197975,
                    "status" : "closed",
                    "_id" : "5112f9577a8f1d370b000002",
                    "team" : ["jasmine"],
                    "name" : "Badger Badger",
                    "author" : "jasmine",
                    "tags" : ["feature"],
                    "likes": ["mushroom", "snake"],
                    "realm": "chaos"
                });

                view = new QuestBig({ model: model });
                view.render();
                return view;
            };

            describe('before edit is clicked', function () {
                var view = createView();

                it('title is visible', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).not.toHaveCss({ display: 'none' });
                });
            });

            describe('after edit is clicked', function () {
                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                });

                it('title is hidden', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).toHaveCss({ display: 'none' });
                });
            });

            describe('if enter is pressed', function () {

                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                    spyOn(view.model, 'save');

                    view.$('[name=name]').val('Mushroom! Mushroom!');

                    var e = $.Event('keyup');
                    e.which = 13; // enter
                    view.$('[name=name]').trigger(e);
                });

                it('title is visible', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).not.toHaveCss({ display: 'none' });
                });

                it('model is saved', function () {
                    expect(view.model.save).toHaveBeenCalledWith({
                        'name': 'Mushroom! Mushroom!',
                        tags: ['feature'],
                        description: ''
                    });
                });
            });

            describe('if enter is pressed on invalid data', function () {

                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                    spyOn(view.model, 'save');

                    view.$('[name=tags]').val('a,,,,,,,,b');

                    var e = $.Event('keyup');
                    e.which = 13; // enter
                    view.$('[name=tags]').trigger(e);
                });

                it('title is hidden', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).toHaveCss({ display: 'none' });
                });

                it('model is not saved', function () {
                    expect(view.model.save).not.toHaveBeenCalled();
                });
            });

            describe('if escape is pressed', function () {

                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                    spyOn(view.model, 'save');

                    view.$('[name=name]').val('Mushroom! Mushroom!');

                    var e = $.Event('keyup');
                    e.which = 27; // escape
                    view.$('[name=name]').trigger(e);
                });

                it('title is visible', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).not.toHaveCss({ display: 'none' });
                });

                it('model is not saved', function () {
                    expect(view.model.save).not.toHaveBeenCalled();
                });

                it('title is not changed', function () {
                    expect(view.$el.find('h2 .quest-big-editable').text()).toEqual('Badger Badger');
                });
            });

            describe('if escape is pressed on invalid data', function () {

                var view;

                beforeEach(function () {
                    view = createView();
                    view.$('.edit').click();
                    spyOn(view.model, 'save');

                    view.$('[name=tags]').val('a,,,,,,,,b');

                    var e = $.Event('keyup');
                    e.which = 27; // escape
                    view.$('[name=tags]').trigger(e);
                });

                it('title is visible', function () {
                    expect(view.$el.find('h2 .quest-big-editable')).not.toHaveCss({ display: 'none' });
                });

                it('model is not saved', function () {
                    expect(view.model.save).not.toHaveBeenCalled();
                });

                it('title is not changed', function () {
                    expect(view.$el.find('h2 .quest-big-editable').text()).toEqual('Badger Badger');
                });
            });
        });

    });
});
