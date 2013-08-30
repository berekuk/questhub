define [
    "underscore"
    "views/proto/common"
    "models/event-collection", "views/event/collection"
    "models/feed/collection", "views/feed/collection"
    "text!templates/realm/page/activity.html"
], (_, Common, EventCollectionModel, EventCollection, FeedCollectionModel, FeedCollection, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            ".events-sv": ->
                collection = new FeedCollectionModel([],
                    limit: 20
                    realm: @model.get('id')
                )
                collection.fetch()
                new FeedCollection collection: collection
                #collection = new EventCollectionModel([],
                #    limit: 50
                #    realm: @model.get('id')
                #)
                #collection.fetch()
                #new EventCollection(collection: collection)
