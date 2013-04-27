define([
    'backbone', 'underscore',
    'views/proto/common',
    'views/user/notifications-box', 'views/user/settings-box',
    'models/current-user', 'models/user-settings',
    'text!templates/current-user.html'
], function (Backbone, _, Common, NotificationsBox, UserSettingsBox, currentUser, UserSettingsModel, html) {
    return Common.extend({

        template: _.template(html),

        events: {
            'click .logout': 'logout',
            'click .settings': 'settingsDialog',
            'click .login-with-persona': 'loginWithPersona',
            'click .notifications': 'notificationsDialog'
        },

        loginWithPersona: function () {
            navigator.id.request();
        },

        getSettingsBox: function () {
            if (!this._settingsBox) {
                this._settingsBox = new UserSettingsBox({
                    model: new UserSettingsModel()
                });
            }
            return this._settingsBox;
        },

        settingsDialog: function() {
            this.getSettingsBox().start();
        },

        notificationsDialog: function () {
            if (!this._notificationsBox) {
                this._notificationsBox = new NotificationsBox({
                    model: this.model
                });
            }
            this._notificationsBox.start();
        },

        needsToRegister: function () {
            if (this.model.get("registered")) {
                return;
            }

            if (
                this.model.get("twitter")
                || (
                    this.model.get('settings')
                    && this.model.get('settings').email
                    && this.model.get('settings').email_confirmed
                )
            ) {
                return true;
            }
            return;
        },

        setPersonaWatch: function () {
            var persona = this.model.get('persona');
            var user = null;
            if (
                this.model.get('settings')
                && this.model.get('settings').email
                && this.model.get('settings').email_confirmed
                && this.model.get('settings').email_confirmed == 'persona'
            ) {
                user = this.model.get('settings').email;
            }

            var view = this;

            navigator.id.watch({
                loggedInUser: user,
                onlogin: function(assertion) {
                    // A user has logged in! Here you need to:
                    // 1. Send the assertion to your backend for verification and to create a session.
                    // 2. Update your UI.
                    $.ajax({
                        type: 'POST',
                        url: '/auth/persona',
                        data: { assertion: assertion },
                        success: function(res, status, xhr) {
                            view.model.fetch();
                        },
                        error: function(xhr, status, err) {
                            Backbone.trigger(
                                'pp:notify',
                                'error',
                                '/auth/persona failed.'
                            );
                        }
                    });
                },
                onlogout: function () {
                    // sometimes persona decides that it should log out the twitter user, so we're trying to prevent it here
                    // it happens often in confusion of localhost:3000 and localhost:3001 in development, since persona only works for :3000
                    if (view.model.get('settings') && view.model.get('settings').email_confirmed == 'persona') {
                        view.backendLogout();
                    }
                }
            });
        },

        afterInitialize: function () {
            this.model.once('sync', this.setPersonaWatch, this);

            this.listenTo(this.model, 'sync', this.checkUser);

            this.listenTo(this.model, 'change', this.render);
            this.listenTo(this.model, 'change', function () {
                var settingsModel = this.model.get('settings') || {};
                // now settings box will show the preview of (probably) correct settings even before it refetches its actual version
                // (see SettingsBox code for the details)
                this.getSettingsBox().model.clear().set(settingsModel);
            });
        },

        checkUser: function () {
            if (this.needsToRegister()) {
                ga('send', 'event', 'register', 'new-dialog');
                Backbone.trigger('pp:navigate', "/register", { trigger: true, replace: true });
                return;
            }
            this.checkEmailConfirmed();
        },

        checkEmailConfirmed: function () {
            if (this.model.get('registered') && this.model.get('settings').email && !this.model.get('settings').email_confirmed) {
                Backbone.trigger(
                    'pp:notify',
                    'warning',
                    'Your email address is not confirmed. Click the link we sent to ' + this.model.get('settings').email + ' to confirm it. (You can resend it from your settings if necessary.)'
                );
            }
        },

        backendLogout: function () {
            $.post('/api/logout').always(function () {
                window.location = '/';
            });
        },

        logout: function () {
            // TODO - fade to black until response
            if (this.model.get('settings') && this.model.get('settings').email_confirmed == 'persona') {
                navigator.id.logout();
            }
            else {
                this.backendLogout();
            }
        }
    });
});
