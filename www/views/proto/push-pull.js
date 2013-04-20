define([
    'underscore',
    'models/current-user',
    'views/proto/common',
], function (_, currentUser, Common) {
    return Common.extend({

        buttonSelector: undefined,
        ownerField: undefined,
        field: undefined,
        hidden: false,

        push: function () { },
        pull: function () { },

        events: {
            "click .push-self": "push",
            "click .pull-self": "pull",
        },

        afterInitialize: function () {
            if (this.options.hidden != undefined) {
                this.hidden = this.options.hidden;
            }
            this.listenTo(this.model, 'change', this.render);
        },

        showButton: function () {
            this.$('.push-pull-button').show();
            this.hidden = false;
        },

        hideButton: function () {
            this.$('.push-pull-button').hide();
            this.hidden = true;
        },

        serialize: function () {
            var currentLogin = currentUser.get('login');

            var params = {
                list: this.model.get(this.field),
                currentUser: currentLogin
            };
            params.my = this.my(currentUser);
            params.meGusta = _.contains(params.list, currentLogin);
            return params;
        },

        afterRender: function () {
            if (this.hidden) {
                this.hideButton();
            }
        },

        features: ['tooltip'],
    });
});
