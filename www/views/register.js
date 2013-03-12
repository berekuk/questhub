// see also for the similar code: views/quest/add
// TODO - refactor them both into views/proto/form
define([
    'underscore', 'jquery', 'views/proto/common',
    'models/user-settings',
    'models/current-user',
    'views/user/settings'
], function (_, $, Common, UserSettingsModel, currentUser, UserSettings) {
    return Common.extend({
        t: 'register',

        events: {
           'click .submit': 'doRegister',
           'keydown [name=login]': 'checkEnter',
           'keyup [name=login]': 'validate'
        },

        subviews: {
            '.settings-subview': function () {
                var model = new UserSettingsModel({
                    notify_likes: 1,
                    notify_comments: 1
                });

                if (this.model.get('settings')) {
                    model.set('email', this.model.get('settings')['email']);
                    model.set('email_confirmed', this.model.get('settings')['email_confirmed']);
                }

                return new UserSettings({ model: model });
            }
        },

        afterInitialize: function () {
            _.bindAll(this);
        },

        afterRender: function () {
            this.validate();
        },

        checkEnter: function (e) {
            if (e.keyCode == 13) {
              this.doRegister();
            }
        },

        getLogin: function () {
            return this.$('[name=login]').val();
        },

        disable: function() {
            this.$('.submit').addClass('disabled');
            this.$('.progress').toggle(this.submitted);
            this.enabled = false;
        },

        enable: function() {
            this.$('.submit').removeClass('disabled');
            this.$('.progress').hide();
            this.enabled = true;
            this.submitted = false;
        },

        validate: function() {
            var login = this.getLogin();
            if (login.match(/^\w*$/)) {
                this.$('.login').removeClass('error');
            }
            else {
                this.$('.login').addClass('error');
                login = undefined;
            }

            if (this.submitted || !login) {
                this.disable();
            }
            else {
                this.enable();
            }
        },

        doRegister: function () {
            if (!this.enabled) {
                return;
            }

            var that = this;

            // TODO - what should we do if login is empty?
            $.post('/api/register', {
                login: this.getLogin(),
                settings: JSON.stringify(this.subview('.settings-subview').deserialize())
            }).done(function (model, response) {
                currentUser.fetch({
                    success: function () {
                        Backbone.trigger('pp:navigate', '/', { trigger: true });
                    },
                    error: function (model, response) {
                        Backbone.trigger('pp:navigate', '/welcome', { trigger: true });
                    }
                });
            })
            .fail(function (response) {
                // TODO - detect "login already taken" exceptions and render them appropriately

                // let's hope that server didn't register the user before it returned a error
                that.submitted = false;
                that.validate();
            })

            this.submitted = true;
            this.validate();
        }
    });
});
