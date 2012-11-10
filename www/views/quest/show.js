pp.views.QuestShow = Backbone.View.extend({
    template: _.template($('#template-quest-show').text()),

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen"
    },

    close: function () {
        this.model.close();
    },

    reopen: function () {
        this.model.reopen();
    },

    initialize: function () {
        this.model.bind('change', this.render, this);
        this.model.fetch();
    },

    render: function () {
        this.$el.html(this.template(this.model.toJSON()));
    },
});
