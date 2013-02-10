pp.views.QuestBig = pp.View.Common.extend({
    t: 'quest-big',

    events: {
        "click .quest-close": "close",
        "click .quest-reopen": "reopen",
        "click .quest-like": "like",
        "click .quest-unlike": "unlike",
        "click .quest-delete": "destroy",
        "dblclick .quest-title": "edit",
        "keypress .quest-edit": "updateOnEnter",
        "blur .quest-edit": "closeEdit"
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

    edit: function () {
        if (!this.isOwned()) {
            return;
        }
        this.$('.quest-edit').show();
        this.$('.quest-title').hide();
        this.$('.quest-edit').focus();
    },

    updateOnEnter: function (e) {
        if (e.keyCode == 13) this.closeEdit();
    },

    closeEdit: function() {
        var value = this.$('.quest-edit').val();
        if (!value) {
            return;
        }
        this.model.save({ name: value });
        this.$('.quest-edit').hide();
        this.$('.quest-title').show();
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
        pp.View.Common.prototype.initialize.apply(this, arguments);

        // FIXME - fix double rendering
        this.model.bind('change', this.render, this);
        pp.app.user.bind('change', this.render, this);

        this.model.fetch();
    },

    isOwned: function () {
        return (pp.app.user.get('login') == this.model.get('user'));
    },

    serialize: function () {
        var params = this.model.toJSON();
        // TODO - should we move this to model?
        params.currentUser = pp.app.user.get('login');
        params.my = this.isOwned();
        if (!params.likes) {
            params.likes = [];
        }
        return params;
    },

    features: ['tooltip'],
});
