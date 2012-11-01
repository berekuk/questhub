pp.views.Dashboard = Backbone.View.extend({

    template: _.template($('script#template-dashboard').text()),

    initialize: function () {
        var login = this.options.user.get('login');

        var view = this;
        var statuses = ['open', 'closed'];
        _.each(['open', 'closed'], function(st) {
            var model = new pp.models.QuestCollection([], {
               'user': login,
               'status': st
            });
            model.fetch();
            view[st + 'Quests'] = new pp.views.QuestCollection({
                quests: model
            });
        });

        this.$el.html(this.template());
        this.$el.find('.open-quests').append(this.openQuests.$el);
        this.$el.find('.closed-quests').append(this.closedQuests.$el);
    }
});
