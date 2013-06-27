define([
    'backbone',
    'models/user'
], function (Backbone, User) {
    return User.extend({

        initialize: function() {
        },

        url: function () {
            return '/api/user/' + this.get('login');
        }
    });
});
