pp.views.QuestShow = Backbone.View.extend({
    template: _.template($('#template-quest-show').text()),

    initialize: function () {
        this.model.bind('change', this.render, this);
        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    },
});
