define [
    "backbone"
    "routers/proto/common"
    "models/shared-models"
    "views/realm/page"
    "views/explore"
    "models/user-collection", "views/user/collection"
    "views/realm/detail-collection", "models/realm"
], (Backbone, Common, sharedModels, RealmPage, Explore, UserCollectionModel, UserCollection, RealmDetailCollection, RealmModel) ->
    class extends Common
        routes:
            "realms": "realms"
            "realm/:realm": "realmPage"
            "realm/:realm/players": "userList"
            "realm/:realm/explore(/:tab)": "explore"
            "realm/:realm/explore/:tab/tag/:tag": "explore"
            "realm/:realm/quest/:id": "realmQuestPage"

        realms: ->
            view = new RealmDetailCollection collection: sharedModels.realms
            view.collection.fetch()
            @appView.setPageView view

        explore: (realm, tab, tag) ->
            view = new Explore(realm: realm)
            view.tab = tab if tab?
            view.tag = tag if tag?
            view.activate()
            @appView.setPageView view

        userList: (realm) ->
            collection = new UserCollectionModel([],
                realm: realm
                sort: "leaderboard"
                limit: 100
            )
            view = new UserCollection(collection: collection)
            collection.fetch()
            @appView.setPageView view

        realmPage: (realm) ->
            model = new RealmModel(id: realm)
            view = new RealmPage(model: model)
            model.fetch()
                .success -> view.activate()

            @appView.setPageView view
