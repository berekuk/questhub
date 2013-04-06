define([
    'jquery',
    'views/quest/add',
    'models/quest-collection',
    'jasmine-jquery'
], function ($, QuestAdd, QuestCollection) {

    describe('quest-add', function () {
        beforeEach(function () {
            spyOn($, 'ajax');
        });

        describe('go button', function () {
            var view;

            beforeEach(function () {
                // it's self-rendering, not calling render()
                view = new QuestAdd({ collection: new QuestCollection() });
            });

            it('not clickable initially', function () {
                expect(view.$('.btn-primary')).toHaveClass('disabled');
            });

            it('clickable after the first symbol', function () {

                view.$('[name=name]').val('A');

                var e = $.Event('keyup');
                e.which = 65; // A
                view.$('[name=name]').trigger(e);

                expect(view.$('.btn-primary')).not.toHaveClass('disabled');
            });
        });

        describe('tags', function () {
            var view;

            beforeEach(function () {
                view = new QuestAdd({ collection: new QuestCollection() });
            });

            it('trimmed tag values sent to server', function () {
                view.$('[name=name]').val('B');
                var e = $.Event('keyup');
                e.which = 66;
                view.$('[name=name]').trigger(e);
                view.$('[name=tags]').val('   foo,  bar , baz ,');

                view.$('.btn-primary').click();

                expect($.ajax.mostRecentCall.args[0].data).toContain('["foo","bar","baz"]');
            });
        });
    });
});
