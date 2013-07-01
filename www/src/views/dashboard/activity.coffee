define [
    "underscore"
    "views/proto/common"
    "models/event-collection", "views/event/collection"
    "text!templates/dashboard/activity.html"
], (_, Common, EventCollectionModel, EventCollection, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            ".activity-subview": ->
                collection = new EventCollectionModel([],
                    limit: 50
                    author: @model.get "login"
                )
                collection.fetch()
                new EventCollection(collection: collection)
