pp.views.Comment = pp.View.Common.extend({
    t: 'comment',

    events: {
        "click .delete": "destroy",
        "click .edit": "edit",
        "blur .comment-edit": "closeEdit",
        'mouseenter': function (e) {
            this.subview('.likes').showButton();
        },
        'mouseleave': function (e) {
            this.subview('.likes').hideButton();
        }
    },

    subviews: {
        '.likes': function () {
            return new pp.views.Like({ model: this.model, showButton: false, ownerField: 'author' });
        }
    },

    edit: function () {
        if (!this.isOwned()) {
            return;
        }
        this.$('.comment-edit').show();
        this.$('.comment-content').hide();
        this.$('.comment-edit').focus();
        this.$('.comment-edit').autosize();
    },

    closeEdit: function() {
        var edit = this.$('.comment-edit');
        if (edit.attr('disabled')) {
            return; // already saving
        }

        var value = edit.val();
        if (!value) {
            return; // empty comments are forbidden
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
                        pp.app.onError(model, xhr);
                        edit.attr('disabled', false);
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
