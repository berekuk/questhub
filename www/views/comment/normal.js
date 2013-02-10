pp.views.Comment = pp.View.Common.extend({
    t: 'comment',

    events: {
        "click .comment-delete": "destroy"
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
        params.my = (pp.app.user.get('login') == params.author);
        return params;
    },
});
