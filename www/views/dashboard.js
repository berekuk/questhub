pp.views.Dashboard = Backbone.View.extend({

    events: {
        "click .quest-add-dialog": "newQuestDialog",
    },

    template: _.template($('script#template-dashboard').text()),

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
            pp.app.router.navigate("/#welcome", { trigger: true });
            return;
        }
        this.render();
    },

    render: function() {
        var login = this.model.get('login');

        // create self.openQuests and self.closedQuests
        var view = this;
        var statuses = ['open', 'closed'];
        _.each(['open', 'closed'], function(st) {
            var collection = new pp.models.QuestCollection([], {
               'user': login,
               'status': st
            });
            collection.fetch();
            view[st + 'Quests'] = new pp.views.QuestCollection({
                quests: collection
            });
        });
        this.questViews = view;

        this.user = new pp.views.UserBig({
            model: this.model
        });
        this.user.render();

        // self-render
        this.$el.html(this.template());
        this.$el.find('.open-quests').append(this.openQuests.$el);
        this.$el.find('.closed-quests').append(this.closedQuests.$el);
        this.$el.find('.user').append(this.user.$el);

        var currentUser = pp.app.user.get('login');
        if (currentUser && currentUser == login) {
          this.$el.find('.new-quest').show();
        }
    },

    newQuestDialog: function() {
        var questAdd = new pp.views.QuestAdd({
          collection: this.openQuests.options.quests
        });
        this.$el.append(questAdd.$el);
    },
});
