define [
  "underscore",
  "views/proto/paged-collection",
  "views/feed/item",
  "text!templates/feed/collection.html"
], ( _, PagedCollection, FeedItem, html) ->
    class extends PagedCollection
        template: _.template html
        listSelector: ".feed-collection"
        pageSize: 50
        initialize: ->
            super
            @listenTo Backbone, "pp:quest-add", (model) -> @collection.fetch()

        generateItem: (model) ->
            new FeedItem model: model
