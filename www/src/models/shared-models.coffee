define ["backbone", "models/realm-collection", "models/current-user"], (Backbone, RealmCollectionModel, currentUser) ->
    realms = new RealmCollectionModel()
    realms: realms
    currentUser: currentUser

