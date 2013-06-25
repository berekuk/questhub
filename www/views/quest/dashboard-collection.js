define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'views/quest/collection',
    'views/progress', 'views/progress/big',
    'text!templates/dashboard-quest-collection.html'
], function (_, Common, currentUser, QuestCollection, Progress, ProgressBig, html) {

    return Common.extend({
        template: _.template(html),

        subviews: {
            '.quests': function () {
                return new QuestCollection({
                    collection: this.collection,
                    showRealm: true,
                    user: this.options.user, // FIXME - get this from collection instead?
                    sortable: this.options.sortable
                });
            },
            '.progress-subview': function () {
                return new ProgressBig();
            },
            '.order-progress-subview': function () {
                return new Progress();
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
                this.subview('.progress-subview').off();
                this.fetched = true;
                view.showOrHide();
            });
            this.subview('.progress-subview').on();
        },

        showOrHide: function () {
            var innerEl = this.$el.find('.quest-collection-inner');
            if (this.fetched) {
                innerEl.show();
                if (!this.collection.length) {
                    this.$('.quest-filter').hide();
                }
                else {
                    this.$('.quest-filter').show();
                }
            }
            else {
                innerEl.hide();
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

            this.listenTo(this.subview('.quests'), 'save-order', function () {
                this.subview('.order-progress-subview').on();
            });
            this.listenTo(this.subview('.quests'), 'order-saved', function () {
                this.subview('.order-progress-subview').off();
            });
        }
    });
});
