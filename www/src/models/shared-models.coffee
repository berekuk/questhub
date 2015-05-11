define [
    "backbone"
    "models/realm-collection", "models/current-user"
], (Backbone, RealmCollectionModel, currentUser) ->
    realms = new RealmCollectionModel()

    result =
        realms: realms
        currentUser: currentUser
        preload: (cb) ->
            realmsFetched = false
            currentUserFetched = false
            cbCalled = false

            isReady = -> realmsFetched and currentUserFetched
            checkReady = ->
                return if cbCalled
                return unless isReady()
                cbCalled = true
                cb()

            realms.fetch().success -> realmsFetched = true; checkReady()
            currentUser.fetch().success -> currentUserFetched = true; checkReady()

