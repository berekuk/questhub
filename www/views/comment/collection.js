pp.views.CommentCollection = pp.View.AnyCollection.extend({

    t: 'comment-collection',

    events: {
        'click .submit': 'postComment',
        'keyup [name=comment]': 'validate'
    },

    serialize: function () {
        return { currentUser: pp.app.user.get('login') };
    },

    generateItem: function (model) {
        return new pp.views.Comment({ model: model });
    },

    listSelector: '.comments-list',

    afterInitialize: function () {
        this.listenTo(this.collection, 'add', function () {
            this.$('[name=comment]').removeAttr('disabled');
            this.$('[name=comment]').val('');
        });
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
    },

    validate: function (e) {
        if ($(e.target).val()) {
            this.$('.submit').removeClass('disabled');
        }
        else {
            this.$('.submit').addClass('disabled');
        }
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
});
