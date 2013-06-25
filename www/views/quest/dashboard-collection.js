define([
    'underscore',
    'views/proto/common',
    'views/quest/collection',
    'text!templates/dashboard-quest-collection.html'
], function (_, Common, QuestCollection, html) {

    return Common.extend({
        template: _.template(html),

        subviews: {
            '.quests': function () {
                return new QuestCollection({
                    collection: this.collection,
                    showRealm: true,
                    user: this.options.user // FIXME - get this from collection instead?
                });
            }
        },

        events: {
            'click .show-tags': function (e) {
                if (e.currentTarget.checked) {
                    this.$('.quests-list').removeClass('quests-list-tagless');
                }
                else {
                    this.$('.quests-list').addClass('quests-list-tagless');
                }
            },
        },

        afterInitialize: function () {
            var view = this;
            this.listenTo(this.collection, 'reset add remove', function () {
                view.showOrHide();
            });
        },

        showOrHide: function () {
            if (this.collection.length) {
                this.$el.show();
            }
            else {
                this.$el.hide();
            }

            var length = this.collection.length;
            if (this.collection.gotMore) {
                length += '+';
            }
            this.$('.quest-collection-header-count').text(length);
        },

        serialize: function () {
            return {
                caption: this.options.caption,
                length: this.collection.length,
                collection: this.collection
            };
        },

        afterRender: function () {
            this.showOrHide();
        }
    });
});
