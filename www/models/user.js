pp.models.User = Backbone.Model.extend({

    url: function () {
        return '/api/get_login';
    }
});
