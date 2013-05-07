define([
    'underscore',
    'views/proto/common',
    'models/quest-collection',
    'views/quest/collection',
    'models/current-user',
    'text!templates/explore.html'
], function (_, Common, QuestCollectionModel, QuestCollection, currentUser, html) {
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
            'latest': { order: 'desc', showStatus: true },
            'unclaimed': { unclaimed: 1, sort: 'leaderboard' },
            'open': { status: 'open', sort: 'leaderboard' },
            'closed': { status: 'closed', sort: 'leaderboard' },
            'watched-by-me': { order: 'desc', watchedByMe: true, showStatus: true }
        },

        realm: function () {
            return this.options.realm;
        },

        tabSubview: function () {
            var options = _.clone(this.name2options[this.tab]);
            options.realm = this.realm();

            if (options.watchedByMe) {
                if (!currentUser.get('login')) {
                    Backbone.trigger('pp:navigate', '/welcome', { trigger: true, replace: true });
                    // fake empty collection, just to get us going until navigate event is processed
                    return new QuestCollection({ collection: new QuestCollection() });
                }
                options.watchers = currentUser.get('login');
            }

            if (this.tag != undefined) {
                options.tags = this.tag;
            }
            return this.createSubview(options);
        },

        createSubview: function (options) {

            options.limit = 100;
            var collection = new QuestCollectionModel([], options);
            collection.fetch();

            return new QuestCollection({
                collection: collection,
                showAuthor: true,
                showStatus: options.showStatus
            });
        },

        switchTab: function (e) {
            var tab = $(e.target).attr('data-explore-tab');
            this.switchTabByName(tab);

            var url = '/' + this.realm() + '/explore/' + tab;
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
            return {
                tag: this.tag,
                currentUser: currentUser.get('login')
            };
        },

        afterRender: function () {
            this.$('[data-explore-tab=' + this.tab + ']').parent().addClass('active');
        },

        removeFilter: function () {
            Backbone.trigger('pp:navigate', '/' + this.realm() + '/explore/' + this.tab, { trigger: true });
        }
    });
});
