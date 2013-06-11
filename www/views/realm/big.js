define([
    'settings',
    'views/proto/common',
    'models/current-user',
    'text!templates/realm-detail.html'
], function (settings, Common, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .realm-follow': 'follow',
            'click .realm-unfollow': 'unfollow'
        },

        follow: function () {
            var that = this;
            currentUser.followRealm(this.model.get('id'))
            .always(function () {
                currentUser.fetch()
                .done(function () {
                    that.render();
                });
            });
        },

        unfollow: function () {
            var that = this;
            currentUser.unfollowRealm(this.model.get('id'))
            .always(function () {
                currentUser.fetch()
                .done(function () {
                    that.render();
                });
            });
        },

        serialize: function () {
            var params = this.model.toJSON();
            params.currentUser = currentUser;
            return params;
        }
    });
});
