pp.views.Dashboard = pp.View.Common.extend({

    t: 'dashboard',

    activated: false,

    events: {
        "click .quest-add-dialog": "newQuestDialog",
    },

    subviews: {
        '.user': function () {
            return new pp.views.UserBig({
                model: this.model
            }); // TODO - fetch or not?
        },
        '.open-quests': function () { return this.createQuestSubview('open') },
        '.closed-quests': function () { return this.createQuestSubview('closed') }
    },

    createQuestSubview: function (st) {
        var login = this.model.get('login');
        var collection = new pp.models.QuestCollection([], {
           'user': login,
           'status': st,
            'limit': 30
        });
        collection.comparator = function(m1, m2) {
            if (m1.id > m2.id) return -1; // before
            if (m2.id > m1.id) return 1; // after
            return 0; // equal
        };
        collection.fetch();

        return new pp.views.QuestCollection({
            collection: collection
        });
    },

    afterRender: function () {
        var currentUser = pp.app.user.get('login');
        if (currentUser && currentUser == this.model.get('login')) {
            this.$('.new-quest').show();
        }
    },

    newQuestDialog: function() {
        var questAdd = new pp.views.QuestAdd({
          collection: this.subview('.open-quests').collection
        });
        this.$el.append(questAdd.$el);
    },
});
