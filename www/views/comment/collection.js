pp.views.CommentCollection = pp.View.AnyCollection.extend({

    t: 'comment-collection',

    events: {
        'click .submit': 'postComment',
        'keyup [name=comment]': 'validate'
    },

    celem: function () {
        return this.$('[name=comment]');
    },

    serialize: function () {
        return { currentUser: pp.app.user.get('login') };
    },

    generateItem: function (model) {
        return new pp.views.Comment({ model: model });
    },

    listSelector: '.comments-list',

    afterInitialize: function () {
        _.bindAll(this, 'onError');
        this.listenTo(this.collection, 'add', this.resetForm);
        pp.View.AnyCollection.prototype.afterInitialize.apply(this, arguments);
    },

    // set the appropriate "add comment" button style
    validate: function (e) {
        var text = this.celem().val();
        if (text) {
            this.$('.submit').removeClass('disabled');
            this.$('.comment-preview').show();
            this.$('.comment-preview').html(pp.app.view.markdownToHtml(text));
        }
        else {
            this.$('.submit').addClass('disabled');
            this.$('.comment-preview').hide();
        }
    },

    disableForm: function () {
        this.celem().attr({ disabled: 'disabled' });
        this.$('.submit').addClass('disabled');
    },

    resetForm: function () {
        this.celem().removeAttr('disabled');
        this.celem().val('');
        this.validate();
    },

    enableForm: function () {
        // the difference from resetForm() is that we don't clear textarea's val() to prevent the comment from vanishing
        this.celem().removeAttr('disabled');
        this.validate();
    },

    postComment: function() {
        if (this.$('.submit').hasClass('disabled')) {
            return;
        }
        this.disableForm();

        this.collection.create({
            'author': pp.app.user.get('login'),
            'body': this.celem().val()
        },
        {
            'wait': true,
            'error': this.onError
            // on success, 'add' will fire and form will be resetted
            // NB: if we'll implement streaming comments loading, this will need to be fixed
        });
    },

    onError: function(model, response) {
        pp.app.onError(model, response);
        this.enableForm();
    },
});
