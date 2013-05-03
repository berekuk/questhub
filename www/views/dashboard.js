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

        realm: function () {
            return this.options.realm;
        },

        progress: 0,

        subviews: {
            '.user': function () {
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
            options.realm = this.realm();

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

        serialize: function () {
            return {
                my: this.my()
            };
        }
    });
});
