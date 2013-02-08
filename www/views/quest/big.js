pp.views.QuestBig = Backbone.View.extend({
    template: _.template($('#template-quest-big').text()),

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen",
        "click .quest-like": "like",
        "click .quest-unlike": "unlike",
        "click .quest-delete": "destroy"
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

    destroy: function () {
        var that = this;
        bootbox.confirm("Quest and all comments will be destroyed permanently. Are you sure?", function(result) {
            if (result) {
                that.model.destroy({
                    success: function(model, response) {
                                 pp.app.router.navigate("/", { trigger: true });
                             },
                    error: pp.app.onError
                });
            }
        });
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
        this.$el.find('[data-toggle=tooltip]').tooltip();
    }
});
