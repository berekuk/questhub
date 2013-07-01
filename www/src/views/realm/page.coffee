define [
    "underscore"
    "views/proto/common"
    "views/realm/controls"
    "models/event-collection", "views/event/collection"
    "text!templates/realm-page.html"
], (_, Common, RealmControls, EventCollectionModel, EventCollection, html) ->
    Common.extend
        template: _.template(html)
        activeMenuItem: "realm-page"
        activated: false
        subviews:
            ".subview": "eventCollection"
            ".realm-controls-subview": ->
                new RealmControls(model: @model)

        realm: ->
            @model.get "id"

        eventCollection: ->
            collection = new EventCollectionModel([],
                limit: 50
                realm: @realm()
            )
            collection.fetch()
            new EventCollection(collection: collection)
