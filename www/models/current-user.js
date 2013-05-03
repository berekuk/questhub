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

        needsToRegister: function () {
            if (this.get("registered")) {
                return;
            }

            if (
                this.get("twitter")
                || (
                    this.get('settings')
                    && this.get('settings').email
                    && this.get('settings').email_confirmed
                )
            ) {
                return true;
            }
            return;
        }
    });
    var result = new CurrentUser();

    Backbone.listenTo(result, 'change', function (e) {
        if (result.get('registered')) {
            mixpanel.alias(result.get('_id'));
            mixpanel.people.set({
                $username: result.get('login'),
                $name: result.get('login'),
                $email: result.get('settings').email,
                // TODO - fill $created
                notify_likes: result.get('settings').notify_likes,
                notify_comments: result.get('settings').notify_comments,
                notify_invites: result.get('settings').notify_invites
            });
            mixpanel.name_tag(result.get('login'));
        }
    });
    return result; // singleton!
});
