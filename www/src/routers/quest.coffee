define [
    "backbone"
    "routers/proto/common"
    "views/quest/page", "models/quest"
    "models/stencil", "views/stencil/page"
], (Backbone, Common, QuestPage, QuestModel, StencilModel, StencilPage) ->
    class extends Common
        routes:
            "quest/:id": "questPage"
            "realm/:realm/quest/:id": "realmQuestPage"
            "stencil/:id": "stencilPage"
            "realm/:realm/stencil/:id": "realmStencilPage"

        questPage: (id) ->
            model = new QuestModel _id: id
            view = new QuestPage model: model
            model.fetch success: =>
                Backbone.history.navigate "/realm/" + model.get("realm") + "/quest/" + model.id,
                    trigger: true
                    replace: true

                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmQuestPage: (realm, id) ->
            @questPage id

        stencilPage: (id) ->
            model = new StencilModel _id: id
            view = new StencilPage model: model
            model.fetch success: =>
                Backbone.history.navigate "/realm/" + model.get("realm") + "/stencil/" + model.id,
                    trigger: true
                    replace: true
                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmStencilPage: (realm, id) ->
            @stencilPage id
