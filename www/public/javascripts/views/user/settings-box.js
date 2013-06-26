// Here's the problem with modal views: you can't re-render them.
// Because when they have an internal state (background fade), and rendering twice means that you won't be able to close your modal, or it won't render at all.
// I'm not sure I understand it completely, but... I had problems with that.
//
// Because of that, UserSettingsBox and UserSettings are two different views.
//
// Also, separating modal view logic is a Good Thing in any case. This view can become 'views/proto/modal' in the future.
define([
    'underscore',
    'views/proto/common',
    'views/user/settings',
    'models/current-user',
    'text!templates/user-settings-box.html'
], function (_, Common, UserSettings, currentUser, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .btn-primary': 'submit'
        },

        subviews: {
            '.settings-subview': function () {
                return new UserSettings({ model: this.model });
            }
        },

        afterInitialize: function() {
            this.setElement($('#user-settings')); // settings-box is a singleton
        },

        enable: function () {
            this.$('.icon-spinner').hide();
            this.subview('.settings-subview').start();
            this.$('.btn-primary').removeClass('disabled');
        },

        disable: function () {
            this.$('.icon-spinner').show();
            this.$('.btn-primary').addClass('disabled');
            this.subview('.settings-subview').stop();
        },

        start: function () {
            this.render();
            this.$('.modal').modal('show');

            this.disable();
            this.model.clear();

            var that = this;
            this.model.fetch({
                success: function () {
                    that.enable();
                },
                error: function () {
                    Backbone.trigger('pp:notify', 'error', 'Unable to fetch settings');
                    that.$('.modal').modal('hide');
                },
            });
        },

        submit: function() {

            ga('send', 'event', 'settings', 'save');
            this.disable();

            var that = this;
            this.subview('.settings-subview').save({
                success: function() {
                    that.$('.modal').modal('hide');

                    // Just to be safe.
                    // Also, if email was changed, we want to trigger the 'sync' event and show the notify box.
                    currentUser.fetch();
                },
                error: function() {
                    Backbone.trigger('pp:notify', 'error', 'Failed to save new settings');
                    that.$('.modal').modal('hide');
                }
            });
        },
    });
});
