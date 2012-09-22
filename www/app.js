$(function () {
    var appView = new pp.views.App({el: $('#layout')});

    var router = new (Backbone.Router.extend({
        routes: {
            "": "index",
        },

        index: function () {
            var homeView = new pp.views.Home();
            appView.setPageView(homeView);
        },
    }))();

    appView.render();
    Backbone.history.start();
});
