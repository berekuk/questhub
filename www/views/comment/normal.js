pp.views.Comment = Backbone.View.extend({
    template: _.template($('#template-comment').text()),

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

    render: function () {
        var params = this.model.toJSON();
        params.my = (pp.app.user.get('login') == params.author);
        this.setElement($(this.template(params)));
        this.$el.find("time.timeago").timeago();
        return this;
    }
});
