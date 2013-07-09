define [
    "backbone"
    "routers/proto/common"
    "views/quest/page", "models/quest"
    "models/library/quest", "views/library/quest-page"
], (Backbone, Common, QuestPage, QuestModel, LibraryQuestModel, LibraryQuestPage) ->
    class extends Common
        routes:
            "quest/:id": "questPage"
            "realm/:realm/quest/:id": "realmQuestPage"
            "library/:id": "libraryPage"
            "realm/:realm/library/quest/:id": "realmLibraryPage"

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

        libraryPage: (id) ->
            model = new LibraryQuestModel _id: id
            view = new LibraryQuestPage model: model
            model.fetch success: =>
                Backbone.history.navigate "/realm/" + model.get("realm") + "/library/quest/" + model.id,
                    trigger: true
                    replace: true
                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmLibraryPage: (realm, id) ->
            @libraryPage id
