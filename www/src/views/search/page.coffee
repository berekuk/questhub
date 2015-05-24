define [
    "underscore"
    "views/proto/common"
    "models/search/collection"
    "views/search/collection"
    "raw!templates/search/page.html"
], (_, Common, SearchCollectionModel, SearchCollection, html) ->
    class extends Common
        template: _.template html

        subviews:
            ".search-collection-sv": ->
                collection = new SearchCollectionModel([],
                    q: @options.query
                    limit: 30
                )
                collection.fetch()
                new SearchCollection collection: collection

        serialize: ->
            query: @options.query
