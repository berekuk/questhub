define([
    'underscore',
    'views/proto/common',
    'views/user/notifications',
    'text!templates/notifications-box.html'
], function (_, Common, Notifications, html) {
    return Common.extend({
        template: _.template(html),

        events: {
            'click .btn-primary': 'next'
        },

        subviews: {
            '.subview': function () {
                return new Notifications({ model: this.model });
            }
        },

        afterInitialize: function() {
            this.setElement($('#notifications')); // settings-box is a singleton
        },

        start: function () {
            if (!this.current()) {
                return;
            }

            this.render();
            this.$('.modal').modal('show');
        },

        current: function () {
            return _.first(this.model.get('notifications'));
        },

        serialize: function () {
            return this.current();
        },

        next: function () {
            var that = this;

            this.model.dismissNotification(this.current()._id)
            .always(function () {
                that.model.fetch()
                .done(function () {
                    if (!that.current()) {
                        that.$('.modal').modal('hide');
                        return;
                    }
                    that.subview('.subview').render();
                })
                .fail(function() {
                    that.$('.modal').modal('hide');
                });
            });
        },
    });
});
