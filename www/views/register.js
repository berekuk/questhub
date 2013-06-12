// see also for the similar code: views/quest/add
// TODO - refactor them both into views/proto/form
define([
    'underscore', 'jquery', 'views/proto/common',
    'models/user-settings',
    'models/current-user',
    'views/user/settings',
    'views/progress/big',
    'text!templates/register.html'
], function (_, $, Common, UserSettingsModel, currentUser, UserSettings, ProgressBig, html) {
    return Common.extend({
        template: _.template(html),

        activeMenuItem: 'home',

        events: {
           'click .submit': 'doRegister',
           'click .cancel': 'cancel',
           'keydown [name=login]': 'checkEnter',
           'keyup [name=login]': 'editLogin',
           'keyup [name=email]': 'editEmail'
        },

        subviews: {
            '.settings-subview': function () {
                var model = new UserSettingsModel({
                    notify_likes: 1,
                    notify_invites: 1,
                    notify_comments: 1
                });

                if (this.model.get('settings')) {
                    model.set('email', this.model.get('settings')['email']);
                    model.set('email_confirmed', this.model.get('settings')['email_confirmed']);
                }

                return new UserSettings({ model: model });
            },
            '.progress-subview': function () {
                return new ProgressBig();
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
            this.enabled = false;
        },

        enable: function() {
            this.$('.submit').removeClass('disabled');
            this.enabled = true;
            this.submitted = false;
        },

        disableForm: function () {
            this.$('[name=login]').attr({ disabled: 'disabled' });
            this.subview('.settings-subview').stop();
        },

        enableForm: function () {
            this.$('[name=login]').removeAttr('disabled');
            this.subview('.settings-subview').start();
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

        editLogin: function () {
            this.$('.settings-conflict-login').hide();
            this.validate();
        },

        editEmail: function () {
            this.$('.settings-conflict-email').hide();
        },

        doRegister: function () {
            if (!this.enabled) {
                return;
            }

            var that = this;

            ga('send', 'event', 'register', 'submit');
            mixpanel.track('register submit');

            this.subview('.progress-subview').on();

            // TODO - what should we do if login is empty?
            $.post('/api/register', {
                login: this.getLogin(),
                settings: JSON.stringify(this.subview('.settings-subview').deserialize())
            }).done(function (data) {
                if (data.status == 'ok') {
                    ga('send', 'event', 'register', 'ok');
                    mixpanel.track('register ok');

                    currentUser.fetch({
                        success: function () {
                            Backbone.trigger('pp:navigate', '/', { trigger: true });
                        },
                        error: function () {
                            Backbone.trigger('pp:navigate', '/welcome', { trigger: true });
                        }
                    });
                }
                else if (data.status == 'conflict') {
                    ga('send', 'event', 'register', 'conflict');
                    mixpanel.track('register conflict');
                    that.$('.settings-conflict-' + data.reason).show();

                    that.subview('.progress-subview').off();
                    that.submitted = false;
                    that.validate();
                }
                else {
                    alert('unknown backend /register status: ' + data.status);
                }
            })
            .fail(function (response) {
                ga('send', 'event', 'register', 'fail');
                mixpanel.track('register fail');

                // let's hope that server didn't register the user before it returned a error
                that.subview('.progress-subview').off();
                that.submitted = false;
                that.validate();
            });

            this.submitted = true;
            this.validate();
        },

        cancel: function () {
            this.disable();
            this.disableForm();
            this.$('.cancel').addClass('disabled');
            var that = this;

            ga('send', 'event', 'register', 'cancel');
            mixpanel.track('register cancel');

            this.subview('.progress-subview').on();

            $.post('/api/register/cancel')
                .done(function (model, response) {
                    Backbone.trigger('pp:navigate', '/', { trigger: true });
                })
                .fail(function () {
                    that.$('.cancel').removeClass('disabled');
                    that.enableForm();
                    that.validate();
                    that.subview('.progress-subview').off();
                });
        }
    });
});
