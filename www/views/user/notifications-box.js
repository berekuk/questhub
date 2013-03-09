pp.views.NotificationsBox = pp.View.Common.extend({
    events: {
        'click .btn-primary': 'next'
    },

    t: 'notifications-box',

    subviews: {
        '.subview': function () {
            return new pp.views.Notifications({ model: this.model });
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
                pp.app.view.notify('error', 'Failed to update notifications');
                that.$('.modal').modal('hide');
            });
        });
    },
});
