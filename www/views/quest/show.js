pp.views.QuestShow = Backbone.View.extend({
    template: _.template($('#template-quest-show').text()),

    events: {
        "click .quest-close": "close",
    },

    close: function () {
        this.model.close();
    },

    initialize: function () {
        this.model.bind('change', this.render, this);
        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    },
});
