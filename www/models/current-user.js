define([
    'backbone', 'jquery',
    'models/user'
], function (Backbone, $, User) {
    var CurrentUser = User.extend({

        initialize: function () {
        },

        dismissNotification: function (_id) {
            return $.post(this.url() + '/dismiss_notification/' + _id);
        },

        url: function () {
            return '/api/current_user';
        },
    });
    var result = new CurrentUser();
    return result; // singleton!
});
