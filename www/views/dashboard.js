define([
    'underscore',
    'views/proto/common',
    'views/user/big', 'views/quest/collection', 'views/quest/add',
    'models/quest-collection', 'models/current-user',
    'text!templates/dashboard.html'
], function (_, Common, UserBig, QuestCollection, QuestAdd, QuestCollectionModel, currentUser, html) {

    return Common.extend({
        template: _.template(html),

        activated: false,

        events: {
            "click .quest-add-dialog": "newQuestDialog",
        },

        subviews: {
            '.user': function () {
                return new UserBig({
                    model: this.model
                }); // TODO - fetch or not?
            },
            '.open-quests': function () {
                return this.createQuestSubview({ status: 'open', user: this.model.get('login') })
            },
            '.closed-quests': function () {
                return this.createQuestSubview({ status: 'closed', user: this.model.get('login') })
            },
            '.abandoned-quests': function () {
                return this.createQuestSubview({ status: 'abandoned', limit: 5, user: this.model.get('login') })
            }
        },

        createQuestSubview: function (options) {
            options.limit = options.limit || 30;
            options.order = 'desc';
            options.realm = this.options.realm;

            var collection = new QuestCollectionModel([], options);
            collection.fetch();

            return new QuestCollection({
                collection: collection
            });
        },

        afterRender: function () {
            var currentLogin = currentUser.get('login');
            if (currentLogin && currentLogin == this.model.get('login')) {
                this.$('.new-quest').show();
            }
        },

        newQuestDialog: function() {
            var questAdd = new QuestAdd({
              collection: this.subview('.open-quests').collection
            });
            this.$el.append(questAdd.$el);
            ga('send', 'event', 'quest', 'new-dialog');
        },
    });
});
