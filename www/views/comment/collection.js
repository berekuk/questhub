pp.views.CommentCollection = Backbone.View.extend({

    events: {
        'click .submit': 'postComment',
        'keyup [name=comment]': 'validate'
    },

    template: _.template($('#template-comment-collection').text()),

    initialize: function () {
        _.bindAll(this);
        this.options.comments.on('reset', this.onReset, this);
        this.options.comments.on('update', this.render, this);
        this.render();
    },

    render: function (collection) {
        this.$el.html(this.template());
        return this;
    },

    validate: function (e) {
        if ($(e.target).val()) {
            this.$('.submit').removeClass('disabled');
        }
        else {
            this.$('.submit').addClass('disabled');
        }
    },

    renderOne: function (comment) {
        this.$('[name=comment]').attr({ disabled: null });
        this.$('[name=comment]').val('');

        var view = new pp.views.Comment({ model: comment });
        var cl = this.$el.find('.comments-list');
        cl.show();
        cl.append(view.render().el);
    },

    postComment: function() {
        if (this.$('.submit').hasClass('disabled')) {
            return;
        }
        this.$('[name=comment]').attr({ disabled: 'disabled' });

        this.options.comments.create({
            'author': pp.app.user.get('login'),
            'body': this.$('[name=comment]').val()
        },
        {
            'success': this.renderOne,
            'error': this.onError
        });
    },

    onError: function(model, response) {
        pp.app.onError(model, response);
        this.$('[name=comment]').attr({ disabled: null });
        // note that we don't clear textarea's val() to keep the comment from vanishing
    },

    onReset: function () {
        this.options.comments.each(this.renderOne, this);
    }
});
