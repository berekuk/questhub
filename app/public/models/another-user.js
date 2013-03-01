pp.models.AnotherUser = pp.models.User.extend({

    initialize: function () {
        this.on('error', pp.app.onError);
    },

    url: function () {
        return '/api/user/' + this.get('login');
    }
});
