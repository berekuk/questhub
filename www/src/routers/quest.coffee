define [
    "backbone"
    "routers/proto/common"
    "models/current-user"
    "views/quest/page", "models/quest"
    "views/quest/add"
    "models/stencil", "views/stencil/page"
], (Backbone, Common, currentUser, QuestPage, QuestModel, QuestAdd, StencilModel, StencilPage) ->
    class extends Common
        routes:
            "quest/add": "questAdd"
            "realm/:realm/quest/add": "questAdd"
            "quest/:id": "questPage"
            "realm/:realm/quest/:id": "realmQuestPage"
            "realm/:realm/quest/:id/reply/:reply": "realmQuestPage"
            "stencil/:id": "stencilPage"
            "realm/:realm/stencil/:id": "realmStencilPage"

        questPage: (id, reply) ->
            model = new QuestModel _id: id
            view = new QuestPage
                model: model
                reply: reply

            model.fetch success: =>
                Backbone.history.navigate "/realm/" + model.get("realm") + "/quest/" + model.id,
                    replace: true

                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmQuestPage: (realm, id, reply) ->
            @questPage id, reply

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

        questAdd: (realm) ->
            unless currentUser.get("registered")
                @navigate "/",
                    trigger: true
                    replace: true
                return

            if realm
                Backbone.history.navigate "/quest/add" # we'd have to update url when realm is changed in quest-add dialog otherwise

            view = new QuestAdd(realm: realm)
            @appView.setPageView view
