pp.views.QuestBig = Backbone.View.extend({
    template: _.template($('#template-quest-big').text()),

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen",
        "click .quest-like": "like"
    },

    close: function () {
        this.model.close();
    },

    reopen: function () {
        this.model.reopen();
    },

    like: function () {
        this.model.like();
    },

    initialize: function () {
        // FIXME - fix double rendering
        this.model.bind('change', this.render, this);
        pp.app.user.bind('change', this.render, this);

        this.model.fetch();
    },

    render: function () {
        var params = this.model.toJSON();
        // TODO - should we move this to model?
        params.my = (pp.app.user.get('login') == params.user);
        this.$el.html(this.template(params));
    }
});
