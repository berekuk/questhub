define([
    'jquery',
    'views/quest/add',
    'models/quest-collection',
    'jasmine-jquery'
], function ($, QuestAdd, QuestCollection) {

    describe('quest-add:', function () {
        var view;

        beforeEach(function () {
            spyOn($, 'ajax');

            if (view) {
                view.remove();
            }
            var el = $('<div style="display:none"></div>');
            $('body').append(el);

            // it's self-rendering, not calling render()
            view = new QuestAdd({
                collection: new QuestCollection(),
                el: el
            });
        });

        describe('realm', function () {

            it('can be chosen', function () {
                expect(view.$('.quest-add-realm button')).not.toHaveClass('active');
                view.$('[data-realm-id=europe]').click();
                expect(view.$('.quest-add-realm button')).toHaveClass('active');
            });
        });

        describe('go button', function () {
            it('not clickable initially', function () {
                expect(view.$('.btn-primary')).toHaveClass('disabled');
            });

            it('not clickable after realm is chosen', function () {
                view.$('[data-realm-id=europe]').click();
                expect(view.$('.btn-primary')).toHaveClass('disabled');
            });

            it('not clickable after the first symbol', function () {
                view.$('[name=name]').val('A');

                var e = $.Event('keyup');
                e.which = 65; // A
                view.$('[name=name]').trigger(e);

                expect(view.$('.btn-primary')).toHaveClass('disabled');
            });

            it('clickable after realm is chosen and name entered', function () {
                view.$('[data-realm-id=europe]').click();
                view.$('[name=name]').val('A');

                var e = $.Event('keyup');
                e.which = 65; // A
                view.$('[name=name]').trigger(e);

                expect(view.$('.btn-primary')).not.toHaveClass('disabled');
            });
        });

        describe('tags', function () {
            it('trimmed tag values sent to server', function () {
                view.$('[data-realm-id=europe]').click();

                view.$('[name=name]').val('B');
                var e = $.Event('keyup');
                e.which = 66;
                view.$('[name=name]').trigger(e);

                view.$('[name=tags]').val('   foo,  bar , baz ,');

                view.$('.btn-primary').click();

                expect($.ajax.mostRecentCall.args[0].data).toContain('["bar","baz","foo"]');
            });
        });
    });
});
