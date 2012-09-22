pp.views.Home = Backbone.View.extend({

    template: _.template($('#template-home').text()),

    initialize: function () {
        this.setElement($(this.template()));
        this.$el.find('.quest-collection').append(
            new pp.views.QuestCollection({
                quests: this.options.quests
            }).render().el
        );
    }
});
