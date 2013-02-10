pp.views.UserBig = pp.View.Common.extend({
    // left column of the dashboard page
    t: 'user-big',

    events: {
        'click .settings': 'editSettingsDialog',
    },

    editSettingsDialog: function() {
        var editSettings = new pp.views.UserSettings({
          model: new pp.models.UserSettings()
        });
        this.$el.append(editSettings.$el);
    },

    features: ['tooltip'],
});
