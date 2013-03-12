// left column of the dashboard page
define([
    'views/proto/common',
    'models/current-user'
], function (Common, currentUser) {
    return Common.extend({
        t: 'user-big',

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
            return params;
        },

        features: ['tooltip'],
    });
});
