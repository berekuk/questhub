pp.views.QuestCollection = Backbone.View.extend({

    tag: 'div',

    template: _.template($('#template-quest-collection').text()),

    initialize: function () {
        this.options.quests.on('reset', this.render, this);
        this.options.quests.on('update', this.render, this);
    },

    render: function (collection) {
        if (collection) {
            this.$el.html(this.template({quests: this.options.quests}));
        }
        return this;
    }
});
