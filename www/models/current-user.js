pp.models.CurrentUser = pp.models.User.extend({

    initialize: function () {
    },

    url: function () {
        return '/api/current_user';
    },
});
