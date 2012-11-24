pp.views.QuestBig = Backbone.View.extend({
    template: _.template($('#template-quest-big').text()),

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen",
        "click .quest-like": "like",
        "click .quest-unlike": "unlike"
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

    unlike: function () {
        this.model.unlike();
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
        params.currentUser = pp.app.user.get('login');
        params.my = (params.currentUser == params.user);
        if (!params.likes) {
            params.likes = [];
        }
        this.$el.html(this.template(params));
    }
});
