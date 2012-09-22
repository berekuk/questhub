$(function () {
    var appView = pp.app.view = new pp.views.App({el: $('#layout')});

    var router = pp.app.router = new (Backbone.Router.extend({
        routes: {
            "": "index",
            "quest/add": "questAdd",
            "quests": "quests"
        },

        index: function () {
            appView.setPageView(new pp.views.Home());
        },

        questAdd: function () {
            var questAddView = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(questAddView);
        },

        quests: function () {
            var questCollectionModel = new pp.models.QuestCollection();
            questCollectionModel.fetch();

            appView.setPageView(new pp.views.QuestCollection({
                quests: questCollectionModel
            }));
        }
    }))();

    Backbone.history.start();
});
