define([
    'underscore',
    'models/current-user',
    'views/proto/common',
    'text!templates/like.html'
], function (_, currentUser, Common, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            "click .like": "like",
            "click .unlike": "unlike",
        },

        ownerField: 'user',

        afterInitialize: function () {
            if (this.options.showButton == undefined) {
                this._sb = true;
            }
            else {
                this._sb = this.options.showButton;
            }

            if (this.options.ownerField != undefined) {
                this.ownerField = this.options.ownerField;
            }
            this.listenTo(this.model, 'change', this.render);
        },

        showButton: function () {
            this.$('.like-button').show();
            this._sb = true;
        },

        hideButton: function () {
            this.$('.like-button').hide();
            this._sb = false;
        },

        like: function () {
            this.model.like();
        },

        unlike: function () {
            this.model.unlike();
        },

        serialize: function () {
            var currentLogin = currentUser.get('login');

            var params = {
                likes: this.model.get('likes'),
                my: (currentLogin == this.model.get(this.ownerField)),
                currentUser: currentLogin
            };
            params.meGusta = _.contains(params.likes, params.currentUser);
            return params;
        },

        afterRender: function () {
            if (!this._sb) {
                this.hideButton();
            }
        },

        features: ['tooltip'],
    });
});
