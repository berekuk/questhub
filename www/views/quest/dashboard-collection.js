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
                    user: this.options.user
                });
            }
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
        },

        serialize: function () {
            return {
                caption: this.options.caption,
                collection: this.collection
            };
        },

        afterRender: function () {
            this.showOrHide();
        }
    });
});
