define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'views/quest/collection',
    'text!templates/dashboard-quest-collection.html'
], function (_, Common, currentUser, QuestCollection, html) {

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
                var mode = (e.currentTarget.checked ? 'normal' : 'dense');
                currentUser.setSetting('quest-collection-view-mode', mode);
                this.setViewMode(mode);
            },
        },

        setViewMode: function (mode) {
            if (mode == 'normal') {
                this.$('.quests-list').removeClass('quests-list-tagless');
            }
            else {
                this.$('.quests-list').addClass('quests-list-tagless');
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

            var length = this.collection.length;
            if (this.collection.gotMore) {
                length += '+';
            }
            this.$('.quest-collection-header-count').text(length);
            this.setViewMode(this.getViewMode());
        },

        getViewMode: function () {
            var viewMode = currentUser.getSetting('quest-collection-view-mode');
            viewMode = viewMode || 'normal';
            return viewMode;
        },

        serialize: function () {
            return {
                caption: this.options.caption,
                length: this.collection.length,
                collection: this.collection,
                viewMode: this.getViewMode()
            };
        },

        afterRender: function () {
            this.showOrHide();
        }
    });
});
