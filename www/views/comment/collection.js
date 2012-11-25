pp.views.CommentCollection = Backbone.View.extend({

    events: {
        'click .submit': 'postComment',
        'keyup [name=comment]': 'validate'
    },

    template: _.template($('#template-comment-collection').text()),

    initialize: function () {
        _.bindAll(this);
        this.collection.on('destroy', this.onReset);
        this.collection.on('reset', this.onReset);
        this.collection.on('add', this.renderOne);
    },

    render: function () {
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
        this.$('[name=comment]').removeAttr('disabled');
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

        this.collection.create({
            'author': pp.app.user.get('login'),
            'body': this.$('[name=comment]').val()
        },
        {
            'wait': true,
            'error': this.onError
        });
    },

    onError: function(model, response) {
        pp.app.onError(model, response);
        this.$('[name=comment]').removeAttr('disabled');
        // note that we don't clear textarea's val() to prevent the comment from vanishing
    },

    onReset: function () {
        this.render();
        this.collection.each(this.renderOne);
    }
});
