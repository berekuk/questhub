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
            '.open-quests': function () { return this.createQuestSubview('open') },
            '.closed-quests': function () { return this.createQuestSubview('closed') },
            '.abandoned-quests': function () { return this.createQuestSubview('abandoned', 5) }
        },

        createQuestSubview: function (st, limit) {
            if (limit === undefined) {
                limit = 30;
            }
            var login = this.model.get('login');
            var collection = new QuestCollectionModel([], {
                'user': login,
                'status': st,
                'limit': limit,
                'order': 'desc'
            });
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
        },
    });
});
