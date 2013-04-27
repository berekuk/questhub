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

    Backbone.listenTo(result, 'change', function (e) {
        if (result.get('registered')) {
            mixpanel.identify(result.get('_id'));
            mixpanel.people.set({
                $username: result.get('login'),
                $name: result.get('login'),
                $email: result.get('settings').email,
                // TODO - fill $created
                points: result.get('points'),
                notify_likes: result.get('settings').notify_likes,
                notify_comments: result.get('settings').notify_comments
            });
        }
    });
    return result; // singleton!
});
