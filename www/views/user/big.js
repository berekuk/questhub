// left column of the dashboard page
define([
    'underscore',
    'views/proto/common',
    'models/current-user',
    'text!templates/user-big.html'
], function (_, Common, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        realm: function () {
            return this.options.realm;
        },

        events: {
            'click .settings': 'settingsDialog',
        },

        settingsDialog: function () {
            Backbone.trigger('pp:settings-dialog');
        },

        serialize: function () {
            var params = this.model.toJSON();

            var currentLogin = currentUser.get('login');
            params.my = (currentLogin && currentLogin == this.model.get('login'));
            params.realm = this.realm();
            return params;
        },

        features: ['tooltip'],
    });
});
