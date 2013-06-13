define([
    'backbone', 'jquery',
    'models/user'
], function (Backbone, $, User) {
    var CurrentUser = User.extend({

        initialize: function () {
            this._tour = {};
        },

        startTour: function () {
            this._tour = {
                'realms': true,
                'profile': true,
                'feed': true
            };
        },

        onTour: function (page) {
            mixpanel.track(page + ' tour')
            var result = this._tour[page];
            this._tour[page] = false; // you can go on each tour only once; let's hope views code is sensible and doesn't call serialize() twice
            return result;
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
        },

        followRealm: function (id) {
            mixpanel.track('follow realm', { realm_id: id })
            return $.post('/api/follow_realm/' + id);
        },
        unfollowRealm: function (id) {
            mixpanel.track('unfollow realm', { realm_id: id });
            return $.post('/api/unfollow_realm/' + id);
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
