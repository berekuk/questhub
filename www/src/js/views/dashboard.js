define([
    'underscore',
    'views/proto/common',
    'views/user/big', 'views/quest/dashboard-collection',
    'models/quest-collection', 'models/current-user',
    'text!templates/dashboard.html'
], function (_, Common, UserBig, DashboardQuestCollection, QuestCollectionModel, currentUser, html) {

    return Common.extend({
        template: _.template(html),

        activated: false,

        activeMenuItem: function () {
            return (this.my() ? 'my-quests' : 'none');
        },

        tab: 'open',

        realm: function () {
            return this.options.realm;
        },

        events: {
            'click ul.dashboard-nav a': 'switchTab'
        },

        subviews: {
            '.user-subview': function () {
                return new UserBig({
                    model: this.model,
                    realm: this.realm()
                });
            },
            '.quests-subview': function () {
                if (this.tab == 'open') {
                    return this.createQuestSubview('open', { sort: 'manual', status: 'open' });
                }
                else if (this.tab == 'closed') {
                    return this.createQuestSubview('completed', { status: 'closed' })
                }
                else if (this.tab == 'abandoned') {
                    return this.createQuestSubview('abandoned', { status: 'abandoned' })
                }
                else {
                    Backbone.trigger('pp:notify', 'error', 'unknown tab ' + this.tab);
                }
            }
        },

        switchTab: function (e) {
            var tab = $(e.target).closest('a').attr('data-dashboard-tab');
            this.switchTabByName(tab);

            var url = '/player/' + this.model.get('login') + '/quest/' + tab;
            Backbone.trigger('pp:navigate', url);
            Backbone.trigger('pp:quiet-url-update');
        },

        switchTabByName: function(tab) {
            this.tab = tab;
            this.rebuildSubview('.quests-subview');
            this.render(); // TODO - why can't we just re-render a subview?
        },

        createQuestSubview: function (caption, options) {
            var that = this;

            if (options.status != 'open') { // open quests are always displayed in their entirety
                options.limit = 100;
            }
            options.order = 'desc';
            options.user = this.model.get('login');

            var collection = new QuestCollectionModel([], options);
            collection.fetch();

            var viewOptions = {
                collection: collection,
                caption: caption,
                user: this.model.get('login')
            };

            if (options.status == 'open' && this.my()) {
                this.listenTo(Backbone, 'pp:quest-add', function (model) {
                    collection.add(model, { prepend: true });
                });
                viewOptions.sortable = true;
            }

            var collectionView = new DashboardQuestCollection(viewOptions);

            return collectionView;
        },

        my: function () {
            var currentLogin = currentUser.get('login');
            if (currentLogin && currentLogin == this.model.get('login')) {
                return true;
            }
            return false;
        },

        tourGotQuest: function () {
            this.$('.newbie-tour-expect-quest').hide();
            this.$('.newbie-tour-got-quest').show();
            mixpanel.track('first quest on tour');
        },

        onTour: function () {
            return this.my() && currentUser.onTour('profile');
        },

        serialize: function () {
            var my = this.my();
            var tour = (my && currentUser.onTour('profile'));
            if (tour) {
                this.listenToOnce(Backbone, 'pp:quest-add', this.tourGotQuest);
            }
            return {
                my: my,
                tour: tour
            };
        },

        afterRender: function () {
            this.$('[data-dashboard-tab=' + this.tab + ']').parent().addClass('active');
        }
    });
});
