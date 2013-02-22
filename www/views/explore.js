pp.views.Explore = pp.View.Common.extend({
    t: 'explore',
    selfRender: true,

    events: {
        'click a.explore-tab': 'switchTab',
    },

    subviews: {
        '#latest-quests-tab': function () {
            return this.questSubview({ order: 'desc' });
        },
        '#unclaimed-quests-tab': function () {
            return this.questSubview({ unclaimed: 1 });
        },
        '#open-quests-tab': function () {
            return this.questSubview({ status: 'open', sort: 'leaderboard' });
        },
        '#closed-quests-tab': function () {
            return this.questSubview({ status: 'closed', sort: 'leaderboard' });
        }
    },

    afterInitialize: function () {
        _.bindAll(this);
    },

    questSubview: function (options) {

        options.limit = 100;
        var collection = new pp.models.QuestCollection([], options);

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

        return new pp.views.QuestCollection({
            collection: collection,
            showAuthor: true
        });
    },

    switchTab: function (e) {
        var tab = $(e.target).attr('data-explore-tab');
        this.switchTabByName(tab);
        pp.app.router.navigate('/explore/' + tab);
    },

    switchTabByName: function(tab) {
        this.$('.nav > li').removeClass('active');
        var el = this.$('[data-explore-tab=' + tab + ']');
        el.parent().addClass('active');

        this.$('.explore-tab-content').addClass('hide');
        this.subview('#' + tab + '-quests-tab').$el.removeClass('hide');
    }
});
