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
            "realm/:realm/stencil/:id/quests": "realmStencilPageQuests"
            "realm/:realm/stencil/:id/reply/:reply": "stencilReply"

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

        stencilPage: (id, tab, reply) ->
            model = new StencilModel _id: id
            view = new StencilPage
                model: model
                tab: tab
                reply: reply

            model.fetch success: =>
                Backbone.history.navigate view.url(),
                    replace: true
                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmStencilPage: (realm, id) ->
            @stencilPage id, 'comments'

        realmStencilPageQuests: (realm, id) ->
            @stencilPage id, 'quests'

        stencilReply: (realm, id, reply) ->
            @stencilPage id, 'comments', reply

        questAdd: (realm) ->
            unless currentUser.get("registered")
                @navigate "/",
                    trigger: true
                    replace: true
                return

            if realm
                # we'd have to update url when realm is changed in quest-add dialog otherwise
                Backbone.history.navigate "/quest/add", replace: true

            view = new QuestAdd(realm: realm)
            @appView.setPageView view
