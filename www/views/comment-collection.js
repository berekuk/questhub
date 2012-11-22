pp.views.CommentCollection = Backbone.View.extend({

    events: {
        'click .submit': 'addComment'
    },

    template: _.template($('#template-comment-collection').text()),

    initialize: function () {
        this.options.comments.on('reset', this.render, this);
        _.bindAll(this);
    },

    render: function (collection) {
        this.$el.html(this.template({ comments: this.options.comments }));
        return this;
    },

    addComment: function() {
        this.options.comments.create({
            'body': this.$('[name=comment]').val()
        },
        {
            'success': this.onSuccess,
            'error': pp.app.onError
        });
    },

    onSuccess: function (model) {
        this.render();
    }
});
