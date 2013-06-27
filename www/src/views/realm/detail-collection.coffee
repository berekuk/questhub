define ["views/realm/big", "views/proto/any-collection", "models/current-user", "text!templates/realm-detail-collection.html"], (RealmBig, AnyCollection, currentUser, html) ->
    AnyCollection.extend
        template: _.template(html)
        generateItem: (model) ->
            new RealmBig(model: model)

        className: "realm-detail-collection"
        listSelector: ".realm-detail-collection-list"
        activeMenuItem: "realms"
        serialize: ->
            tour: currentUser.onTour("realms")


