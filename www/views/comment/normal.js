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

        this.$el.html(this.template(params));

        var subview = new pp.views.UserSmall({ login: this.model.get('author') });
        subview.setElement(this.$('.player'));
        subview.render();

        this.$el.find("time.timeago").timeago();
        return this;
    }
});
