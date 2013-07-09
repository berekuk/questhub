define [
    "underscore"
    "views/proto/common"
    "models/library/collection", "views/library/collection"
    "views/library/quest-add"
    "text!templates/library/overview.html"
], (_, Common, CollectionModel, Collection, QuestAdd, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .add-library-quest": "addDialog"

        subviews:
            '.library-collection-sv': ->
                collection = new CollectionModel [],
                    realm: @model.id
                view = new Collection collection: collection
                collection.fetch()
                view

        addDialog: ->
            new QuestAdd realm: @model.id
