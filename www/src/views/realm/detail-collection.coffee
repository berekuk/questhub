define [
  "underscore"
  "views/proto/any-collection"
  "views/realm/detail"
  "models/current-user",
  "raw!templates/realm/detail-collection.html"
], (_, AnyCollection, RealmDetail, currentUser, html) ->
    AnyCollection.extend
        template: _.template(html)
        generateItem: (model) ->
            new RealmDetail(model: model)

        className: "realm-detail-collection"
        listSelector: ".realm-detail-collection-list"
        activeMenuItem: "realms"
        pageTitle: -> "Realms"

        serialize: ->
            tour: currentUser.onTour("realms")
