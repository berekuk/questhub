$(function () {
    var appView = pp.app.view = new pp.views.App({el: $('#layout')});

    var router = pp.app.router = new (Backbone.Router.extend({
        routes: {
            "": "dashboard",
            "quest/add": "questAdd",
            "quest/:id": "questShow",
        },

        questAdd: function () {
            var questAddView = new pp.views.QuestAdd({ model: new pp.models.Quest() });
            appView.setPageView(questAddView);
            setActiveMenuItem('add-quest');
        },

        questShow: function (id) {
            var questShowView = new pp.views.QuestShow({ model: new pp.models.Quest({ id: id }) });
            appView.setPageView(questShowView);
        },

        dashboard: function () {
            var user = new pp.models.User();
            user.fetch({
                success: function(model, response) {
                    if (!user.get("logged")) {
                        appView.setPageView(new pp.views.Home());
                    }
                    else {
                        var questCollectionModel = new pp.models.QuestCollection();
                        questCollectionModel.fetch();

                        appView.setPageView(new pp.views.QuestCollection({
                            quests: questCollectionModel
                        }));
                    }
                    setActiveMenuItem('home');
                },
                error: function() {
                    alert("user info fetch error");
                },
            });

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
