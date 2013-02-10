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
        var edit = this.$('.comment-edit');
        var value = edit.val();
        if (!value) {
            return;
        }

        var that = this;
        edit.attr('disabled', 'disabled');
        this.model.save({ body: value }, {
            success: function () {
                that.model.fetch({
                    success: function () {
                        edit.attr('disabled', false);
                        edit.hide();
                        this.$('.comment-content').show();
                        that.render();
                    },
                    error: function (model, xhr, options) {
                        console.log('error - fetch failed');
                        console.log(xhr);
                        edit.attr('disabled', false);
                        // pp.app.onError(model, { response: 'saveFailed'
                    },
                });
            },
            error: function (model, xhr) {
                pp.app.onError(model, xhr);
                edit.attr('disabled', false);
            }
        });
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

    features: ['timeago'],

    serialize: function () {
        var params = this.model.toJSON();
        params.my = this.isOwned();
        return params;
    },

    isOwned: function () {
        return (pp.app.user.get('login') == this.model.get('author'));
    },
});
