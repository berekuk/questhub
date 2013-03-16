define([
    'underscore', 'markdown',
    'views/proto/any-collection',
    'models/current-user',
    'views/user/signin',
    'views/comment/normal',
    'text!templates/comment-collection.html'
], function (_, markdown, AnyCollection, currentUser, Signin, Comment, html) {
    return AnyCollection.extend({

        template: _.template(html),

        events: {
            'click .submit': 'postComment',
            'keyup [name=comment]': 'validate'
        },

        subviews: {
            '.signin': function () { return new Signin(); }
        },

        celem: function () {
            return this.$('[name=comment]');
        },

        serialize: function () {
            return { currentUser: currentUser.get('login') };
        },

        generateItem: function (model) {
            return new Comment({ model: model });
        },

        listSelector: '.comments-list',

        afterInitialize: function () {
            this.listenTo(this.collection, 'add', this.resetForm);
            AnyCollection.prototype.afterInitialize.apply(this, arguments);
        },

        afterRender: function () {
            AnyCollection.prototype.afterRender.apply(this, arguments);
            this.$('[name=comment]').autosize();
        },

        // set the appropriate "add comment" button style
        validate: function (e) {
            var text = this.celem().val();
            if (text) {
                this.$('.submit').removeClass('disabled');
                this.$('.comment-preview').show();
                this.$('.comment-preview').html(markdown(text));
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
                'author': currentUser.get('login'),
                'body': this.celem().val()
            },
            {
                'wait': true,
                'error': this.enableForm,
                // on success, 'add' will fire and form will be resetted
                // NB: if we'll implement streaming comments loading, this will need to be fixed
            });
        },
    });
});
