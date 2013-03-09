pp.views.CurrentUser = pp.View.Common.extend({

    t: 'current-user',

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
            this._settingsBox = new pp.views.UserSettingsBox({
                model: new pp.models.UserSettings()
            });
        }
        return this._settingsBox;
    },

    settingsDialog: function() {
        this.getSettingsBox().start();
    },

    notificationsDialog: function () {
        alert("not implemented");
    },

    needsToRegister: function () {
        if (this.model.get("registered")) {
            console.log('registered');
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
            console.log('needs to register');
            return true;
        }
        console.log('not logged in');
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

        console.log('user: ' + user);

        var that = this;

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
                        console.log('success, updating user');
                        that.model.fetch();
                    },
                    error: function(xhr, status, err) {
                        pp.app.view.notify(
                            'error',
                            '/auth/persona failed.'
                        );
                    }
                });
            },
            onlogout: that.backendLogout
        });
    },

    afterInitialize: function () {
        this.model = pp.app.user;
        this.model.once('sync', this.setPersonaWatch, this);

        this.model.on('all', function(e) { console.log('cuser event: ' + e) }, this);

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
        console.log('current.checkUser');
        if (this.needsToRegister()) {
            console.log('going to /register');
            pp.app.router.navigate("/register", { trigger: true, replace: true });
            return;
        }
        this.checkEmailConfirmed();
    },

    checkEmailConfirmed: function () {
        if (this.model.get('registered') && this.model.get('settings').email && !this.model.get('settings').email_confirmed) {
            pp.app.view.notify(
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
