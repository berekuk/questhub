define([
    'views/proto/common',
    'views/user/big',
    'models/quest-collection',
    'models/current-user',
    'views/quest/collection',
    'views/quest/add',
], function (Common, UserBig, QuestCollectionModel, currentUser, QuestCollection, QuestAdd) {
    return Common.extend({

        t: 'dashboard',

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
                'limit': limit
            });
            collection.comparator = function(m1, m2) {
                if (m1.id > m2.id) return -1; // before
                if (m2.id > m1.id) return 1; // after
                return 0; // equal
            };
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
