pp.views.UserBig = pp.View.Common.extend({
    // left column of the dashboard page
    t: 'user-big',

    events: {
        'click .settings': 'editSettingsDialog',
    },

    subviews: {
        '.settings-box-subview': 'editSettingsView',
    },

    editSettingsView: function () {
        if (this.editSettings) {
            return this.editSettings;
        }
        this.editSettings = new pp.views.UserSettingsBox({
            model: new pp.models.UserSettings()
        });
        return this.editSettings;
    },

    editSettingsDialog: function() {
        this.editSettings.start();
    },

    serialize: function () {
        var params = this.model.toJSON();

        var currentUser = pp.app.user.get('login');
        params.my = (currentUser && currentUser == this.model.get('login'));
        return params;
    },

    features: ['tooltip'],
});
