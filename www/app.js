$(function () {
    pp.app.user = new pp.models.CurrentUser();

    var appView = pp.app.view = new pp.views.App({el: $('#layout')});

    pp.app.onError = function(model, response) {
        $('#layout > .container').prepend(
            new pp.views.Error({
                response: response
            }).render().el
        );
    };
    pp.app.user.on("error", pp.app.onError);

    var router = pp.app.router = new (Backbone.Router.extend({
        routes: {
            "": "dashboard",
            "welcome": "welcome",
            "register": "register",
            "quest/add": "questAdd",
            "quest/:id": "questShow",
            "player/:login": "anotherDashboard",
        },

        questAdd: function () {
            var view = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(view);
            setActiveMenuItem('add-quest');
        },

        questShow: function (id) {
            var view = new pp.views.QuestShow({ model: new pp.models.Quest({ id: id }) });
            appView.setPageView(view);
        },

        welcome: function () {
            appView.setPageView(new pp.views.Home());
            setActiveMenuItem('home');
        },

        dashboard: function () {
            var dashboard = new pp.views.Dashboard({ model: pp.app.user, current: true });
            appView.setPageView(dashboard);

            // start after setPageView, because dashboard can call back to router,
            // and if if happens in he initializer before setPageView, then we show welcome view and then immediately replace it with (empty!) dashboard
            // FIXME - this is ugly :(
            dashboard.start();

            setActiveMenuItem('home');
        },

        anotherDashboard: function (login) {
            console.log('another dashboard');
            var user = new pp.models.AnotherUser({ login: login });
            var view = new pp.views.Dashboard({ model: user });
            view.start();
            user.fetch();
            appView.setPageView(view);
        },

        register: function () {
            appView.setPageView(new pp.views.Register());
            setActiveMenuItem('home');
        }
    }))();

    function setActiveMenuItem(selector) {
        appView.$el
            .find('.active')
                .removeClass('active')
                .end()
            .find('.menu-item-' + selector)
                .addClass('active');
    }

    Backbone.history.start();
});
