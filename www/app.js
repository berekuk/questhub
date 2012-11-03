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
        },

        questAdd: function () {
            console.log("/#quest/add");
            var questAddView = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(questAddView);
            setActiveMenuItem('add-quest');
        },

        questShow: function (id) {
            console.log("/#quest/:id");
            var questShowView = new pp.views.QuestShow({ model: new pp.models.Quest({ id: id }) });
            appView.setPageView(questShowView);
        },

        welcome: function () {
            console.log("/#welcome");
            appView.setPageView(new pp.views.Home());
            setActiveMenuItem('home');
        },

        dashboard: function () {
            console.log("/#dashboard");

            var dashboard = new pp.views.Dashboard();
            appView.setPageView(dashboard);

            // start after setPageView, because dashboard can call back to router,
            // and if if happens in he initializer before setPageView, then we show welcome view and then immediately replace it with (empty!) dashboard
            // FIXME - this is ugly :(
            dashboard.start();

            setActiveMenuItem('home');
        },

        register: function () {
            console.log("/#register");
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
