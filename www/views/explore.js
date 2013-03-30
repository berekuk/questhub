define([
    'underscore',
    'views/proto/common',
    'models/quest-collection',
    'views/quest/collection',
    'text!templates/explore.html'
], function (_, Common, QuestCollectionModel, QuestCollection, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click ul.explore-nav a': 'switchTab',
            'click .remove-filter': 'removeFilter'
        },

        subviews: {
            '.explore-tab-content': 'tabSubview'
        },

        tab: 'latest',
        activated: false,

        afterInitialize: function () {
            _.bindAll(this);
        },

        name2options: {
            'latest': { order: 'desc' },
            'unclaimed': { unclaimed: 1, sort: 'leaderboard' },
            'open': { status: 'open', sort: 'leaderboard' },
            'closed': { status: 'closed', sort: 'leaderboard' }
        },

        tabSubview: function () {
            var options = _.clone(this.name2options[this.tab]);
            if (this.tag != undefined) {
                options.tags = this.tag;
            }
            return this.createSubview(options);
        },

        createSubview: function (options) {

            options.limit = 100;
            var collection = new QuestCollectionModel([], options);

            // duplicates server-side sorting logic!
            if (options.sort && options.sort == 'leaderboard') {
                collection.comparator = function(m1, m2) {
                    if (m1.like_count() > m2.like_count()) return -1; // before
                    if (m2.like_count() > m1.like_count()) return 1; // after

                    if (m1.comment_count() > m2.comment_count()) return -1;
                    if (m2.comment_count() > m1.comment_count()) return 1;
                    return 0; // equal
                };
            }
            collection.fetch();
            if (options.sort) {
                collection.sort();
            }

            return new QuestCollection({
                collection: collection,
                showAuthor: true
            });
        },

        switchTab: function (e) {
            var tab = $(e.target).attr('data-explore-tab');
            this.switchTabByName(tab);

            var url = '/explore/' + tab;
            if (this.tag != undefined) {
                url += '/tag/' + this.tag;
            }
            Backbone.trigger('pp:navigate', url);
        },

        switchTabByName: function(tab) {
            this.tab = tab;
            this.initSubviews(); // recreate tab subview
            this.render();
        },

        serialize: function () {
            return { tag: this.tag };
        },

        afterRender: function () {
            this.$('[data-explore-tab=' + this.tab + ']').parent().addClass('active');
        },

        removeFilter: function () {
            Backbone.trigger('pp:navigate', '/explore/' + this.tab, { trigger: true });
        }
    });
});
