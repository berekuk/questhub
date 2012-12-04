pp.models.CurrentUser = pp.models.User.extend({

    initialize: function () {
        this.on('error', pp.app.onError);

        // This is a weird hack to allow dashboard view to render in both of these cases:
        // 1) app is just loaded, user is not fetched yet
        // 1) app is already loaded, user is fetched, and we need to go back to dashboard page
        // Backbone.js doesn't fire 'change' event in the second case, even if I invoke model.fetch() manually.
        //
        // tl;dr: It's weird that I have to track the fetch state in the model, it's probably because I don't understand Backbone.js enough yet.
        this.isFetched = false;
        this.on("change", function () {
            this.isFetched = true;
        }, this);
    },

    url: function () {
        return '/api/current_user';
    },
});
