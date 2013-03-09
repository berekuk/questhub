pp.models.CurrentUser = pp.models.User.extend({

    initialize: function () {
    },

    dismissNotification: function (_id) {
        return $.post(this.url() + '/dismiss_notification/' + _id);
    },

    url: function () {
        return '/api/current_user';
    },
});
