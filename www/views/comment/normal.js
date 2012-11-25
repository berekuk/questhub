pp.views.Comment = Backbone.View.extend({
    template: _.template($('#template-comment').text()),

    events: {
        "click .comment-delete": "destroy"
    },

    destroy: function () {
        this.model.destroy({
            wait: true,
            error: pp.app.onError
        });
    },

    initialize: function () {
        this.setElement($(this.template(this.model.toJSON())));
    }
});
