define [
    "underscore"
    "views/proto/common"
    "models/event-collection", "views/event/collection"
    "text!templates/realm/page/activity.html"
], (_, Common, EventCollectionModel, EventCollection, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            ".events-sv": ->
                collection = new EventCollectionModel([],
                    limit: 50
                    realm: @model.get('id')
                )
                collection.fetch()
                new EventCollection(collection: collection)
