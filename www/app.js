$(function () {
    var appView = pp.app.view = new pp.views.App({el: $('#layout')});

    var router = pp.app.router = new (Backbone.Router.extend({
        routes: {
            "": "index",
            "quest/add": "questAdd",
            "quest/:id": "questShow",
            "quests": "quests"
        },

        index: function () {
            appView.setPageView(new pp.views.Home());
            setActiveMenuItem('home');
        },

        questAdd: function () {
            var questAddView = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(questAddView);
            setActiveMenuItem('quest');
        },

        questShow: function (id) {
            var questShowView = new pp.views.QuestShow({ model: new pp.models.Quest({ id: id }) });
            appView.setPageView(questShowView);
            setActiveMenuItem('quest');
        },

        quests: function () {
            var questCollectionModel = new pp.models.QuestCollection();
            questCollectionModel.fetch();

            appView.setPageView(new pp.views.QuestCollection({
                quests: questCollectionModel
            }));
            setActiveMenuItem('quest');
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
