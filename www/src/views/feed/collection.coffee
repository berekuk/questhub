define [
  "underscore",
  "backbone"
  "views/proto/paged-collection",
  "views/feed/item",
  "raw!templates/feed/collection.html"
], (_, Backbone, PagedCollection, FeedItem, html) ->
    class extends PagedCollection
        template: _.template html
        listSelector: ".feed-collection"
        pageSize: 50
        initialize: ->
            super
            @listenTo Backbone, "pp:quest-add", (model) -> @collection.fetch()

        generateItem: (model) ->
            new FeedItem model: model
