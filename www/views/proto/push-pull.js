define([
    'underscore',
    'models/current-user',
    'views/proto/common',
], function (_, currentUser, Common) {
    return Common.extend({

        buttonSelector: undefined,
        ownerField: undefined,
        field: undefined,

        push: function () { },
        pull: function () { },

        events: {
            "click .push-self": "push",
            "click .pull-self": "pull",
        },

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
            this.$('.push-pull-button').show();
            this._sb = true;
        },

        hideButton: function () {
            this.$('.push-pull-button').hide();
            this._sb = false;
        },

        serialize: function () {
            var currentLogin = currentUser.get('login');

            var params = {
                list: this.model.get(this.field),
                my: (currentLogin == this.model.get(this.ownerField)),
                currentUser: currentLogin
            };
            params.meGusta = _.contains(params.list, params.currentUser);
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
