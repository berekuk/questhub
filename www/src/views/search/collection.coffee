define [
  "underscore",
  "views/proto/paged-collection",
  "views/search/item",
  "raw!templates/search/collection.html"
], ( _, PagedCollection, SearchItem, html) ->
    class extends PagedCollection
        template: _.template html
        listSelector: ".search-collection"
        pageSize: 30

        generateItem: (model) ->
            new SearchItem model: model
