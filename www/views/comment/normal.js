pp.views.Comment = pp.View.Common.extend({
    t: 'comment',

    events: {
        "click .comment-delete": "destroy",
        "dblclick .comment-content": "edit",
        "keypress .comment-edit": "updateOnEnter",
        "blur .comment-edit": "closeEdit"
    },

    edit: function () {
        if (!this.isOwned()) {
            return;
        }
        this.$('.comment-edit').show();
        this.$('.comment-content').hide();
        this.$('.comment-edit').focus();
    },

    updateOnEnter: function (e) {
        if (e.keyCode == 13) this.closeEdit();
    },

    closeEdit: function() {
        var value = this.$('.comment-edit').val();
        if (!value) {
            return;
        }
        this.model.save({ name: value });
        this.$('.comment-edit').hide();
        this.$('.comment-content').show();
    },

    destroy: function () {
        var that = this;
        bootbox.confirm("Are you sure you want to delete this comment?", function(result) {
            if (result) {
                that.model.destroy({
                    wait: true,
                    error: pp.app.onError
                });
            }
        });
    },


    serialize: function () {
        var params = this.model.toJSON();
        params.my = this.isOwned();
        return params;
    },

    isOwned: function () {
        return (pp.app.user.get('login') == this.model.get('author'));
    },
});
