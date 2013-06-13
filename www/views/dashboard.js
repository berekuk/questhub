define([
    'underscore',
    'views/proto/common',
    'views/user/big', 'views/quest/dashboard-collection',
    'views/progress/big',
    'models/quest-collection', 'models/current-user',
    'text!templates/dashboard.html'
], function (_, Common, UserBig, DashboardQuestCollection, ProgressBig, QuestCollectionModel, currentUser, html) {

    return Common.extend({
        template: _.template(html),

        activated: false,

        activeMenuItem: function () {
            return (this.my() ? 'my-quests' : 'none');
        },

        realm: function () {
            return this.options.realm;
        },

        subviews: {
            '.user-subview': function () {
                return new UserBig({
                    model: this.model,
                    open_quests: this.subview('.open-quests'),
                    realm: this.realm()
                });
            },
            '.progress-subview': function () {
                return new ProgressBig();
            },
            '.open-quests': function () {
                return this.createQuestSubview('Open', { status: 'open', user: this.model.get('login') })
            },
            '.closed-quests': function () {
                return this.createQuestSubview('Completed', { status: 'closed', user: this.model.get('login') })
            },
            '.abandoned-quests': function () {
                return this.createQuestSubview('Abandoned', { status: 'abandoned', limit: 5, user: this.model.get('login') })
            }
        },

        progress: 0,

        moreProgress: function () {
            this.progress++;
            if (this.progress == 1) {
                this.subview('.progress-subview').on();
            }
        },

        lessProgress: function () {
            this.progress--;
            if (this.progress == 0) {
                this.subview('.progress-subview').off();
            }
        },

        createQuestSubview: function (caption, options) {
            var that = this;

            options.limit = options.limit || 30;
            options.order = 'desc';

            var collection = new QuestCollectionModel([], options);
            this.moreProgress();
            collection.fetch().always(function () {
                that.lessProgress();
            });

            var collectionView = new DashboardQuestCollection({
                collection: collection,
                caption: caption
            });

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
                this.listenToOnce(Backbone, 'pp:add-quest', this.tourGotQuest);
            }
            return {
                my: my,
                tour: tour
            };
        }
    });
});
