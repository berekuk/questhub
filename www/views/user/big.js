pp.views.UserBig = pp.View.Common.extend({
    // left column of the dashboard page
    t: 'user-big',

    events: {
        'click .settings': 'settingsDialog',
    },

    settingsDialog: function () {
        pp.app.view.userSettingsDialog();
    },

    serialize: function () {
        var params = this.model.toJSON();

        var currentUser = pp.app.user.get('login');
        params.my = (currentUser && currentUser == this.model.get('login'));
        return params;
    },

    features: ['tooltip'],
});
