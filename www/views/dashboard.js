pp.views.Dashboard = Backbone.View.extend({

    events: {
        "click .quest-add-dialog": "newQuestDialog",
    },

    template: _.template($('script#template-dashboard').text()),

    initialize: function() {
        this.user = new pp.views.UserBig({
            model: this.model
        });
    },

    // separate function because of ugly hack in router code, see router code
    start: function() {
        if (!this.options.current) {
            this.model.on('change', this.render, this);
            return;
        }
        this.model.on('change', this.checkLogged, this);

        // see models/current-user.js for the explanation
        if (this.model.isFetched) {
            this.model.trigger('change');
        }
    },

    checkLogged: function() {
        if (!this.model.get("registered")) {
            pp.app.router.navigate("/welcome", { trigger: true });
            return;
        }
        this.render();
    },

    // delay subviews initialization - they depend on model.get('login') which is fetched asynchrohously
    initializeQuestViews: function() {

        var login = this.model.get('login');

        // create self.openQuests and self.closedQuests
        var view = this;
        var statuses = ['open', 'closed'];
        _.each(['open', 'closed'], function(st) {
            var collection = new pp.models.QuestCollection([], {
               'user': login,
               'status': st
            });
            collection.comparator = function(m1, m2) {
                if (m1.id > m2.id) return -1; // before
                if (m2.id > m1.id) return 1; // after
                return 0; // equal
            };
            collection.fetch();
            view[st + 'Quests'] = new pp.views.QuestCollection({
                quests: collection
            });
        });
        this.questViews = view;
    },

    render: function() {
        this.initializeQuestViews();
        this.user.render();

        // self-render
        this.$el.html(this.template());

        this.user.setElement(this.$('.user')).render();
        this.openQuests.setElement(this.$('.open-quests')).render();
        this.closedQuests.setElement(this.$('.closed-quests')).render();

        var currentUser = pp.app.user.get('login');
        if (currentUser && currentUser == this.model.get('login')) {
          this.$('.new-quest').show();
        }
    },

    newQuestDialog: function() {
        var questAdd = new pp.views.QuestAdd({
          collection: this.openQuests.options.quests
        });
        this.$el.append(questAdd.$el);
    },
});
