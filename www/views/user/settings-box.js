// Here's the problem with modal views: you can't re-render them.
// Because when they have an internal state (background fade), and rendering twice means that you won't be able to close your modal, or it won't render at all.
// I'm not sure I understand it completely, but... I had problems with that.
//
// Also, separating modal view logic is a Good Thing in any case. This view can become 'pp.View.Modal' in the future.
pp.views.UserSettingsBox = pp.View.Common.extend({
    events: {
        'click .btn-primary': 'submit'
    },

    t: 'user-settings-box',

    subviews: {
        '.settings-subview': function () {
            return this.userSettings;
        }
    },

    afterInitialize: function() {
        this.userSettings = new pp.views.UserSettings({ model: this.model });
    },

    start: function () {
        this.$('.modal').modal('show');
        this.model.fetch();
    },

    submit: function() {
        var that = this;
        this.userSettings.save({
            success: function() {
                that.$('.modal').modal('hide');
            },
            failure: function() {
                alert('modal submit failed!');
            }
        });
    },
});
