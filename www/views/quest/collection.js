pp.views.QuestCollection = Backbone.View.extend({

    template: _.template($('#template-quest-collection').text()),

    initialize: function () {
        this.options.quests.on('reset', this.onReset, this);
        this.options.quests.on('add', this.onAdd, this);
    },

    render: function (collection) {
        this.$el.html(this.template());
        this.options.quests.each(this.renderOne, this);
        return this;
    },

    renderOne: function(quest) {
        var view = new pp.views.QuestSmall({model: quest});
        var ql = this.$el.find('.quests-list');
        ql.show(); // quests table is hidden initially - see https://github.com/berekuk/play-perl/issues/61
        ql.append(view.render().el);
    },

    onAdd: function () {
        this.render();
    },

    onReset: function () {
        this.render();
    }
});
