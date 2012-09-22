$(function () {
    var appView = new pp.views.App({el: $('#layout')});

    var router = new (Backbone.Router.extend({
        routes: {
            "": "index",
            "quest/add": "questAdd"
        },

        index: function () {
            var homeView = new pp.views.Home();
            appView.setPageView(homeView);
        },
        questAdd: function() {
            var questAddView = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(questAddView);
        },
    }))();
//
    appView.render();
    Backbone.history.start();
});
