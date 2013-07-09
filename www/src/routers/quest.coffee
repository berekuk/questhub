define [
    "backbone"
    "routers/proto/common"
    "views/quest/page", "models/quest"
    "models/library-quest", "views/library/quest"
], (Backbone, Common, QuestPage, QuestModel, LibraryQuestModel, LibraryQuestPage) ->
    class extends Common
        routes:
            "quest/:id": "questPage"
            "realm/:realm/quest/:id": "realmQuestPage"
            "library/:id": "libraryPage"
            "realm/:realm/library/:id": "realmLibraryPage"

        questPage: (id) ->
            model = new QuestModel(_id: id)
            view = new QuestPage(model: model)
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
            model = new LibraryQuestModel
                name: "Read a book"
                description: """
                  1. Choose any book you like.
                  1. Read it.
                  1. ...
                  1. PROFIT!
                """
                stat:
                    players: 98
                realm: "perl"
            view = new LibraryQuestPage model: model
            @appView.setPageView view

        realmLibraryPage: (realm, id) ->
            @libraryPage id
