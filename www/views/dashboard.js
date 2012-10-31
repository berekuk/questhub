pp.views.Dashboard = Backbone.View.extend({

    template: _.template($('script#template-dashboard').text()),

    initialize: function () {
        var login = this.options.user.get('login');

        var myQuests = new pp.models.QuestCollection([], { user: login });
        myQuests.fetch();

        var myQuestsView = new pp.views.QuestCollection({
            quests: myQuests
        });
        this.quests = myQuestsView;

        this.$el.html(this.template());
        this.$el.find('.dashboard-view-container').append(this.quests.$el);
        this.quests.render();
    }
});
