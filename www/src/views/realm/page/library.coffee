define [
    "underscore"
    "views/proto/common"
    "models/library/collection", "views/library/collection"
    "text!templates/realm-page/library.html"
], (_, Common, LibraryCollectionModel, LibraryCollection, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            '.library-collection-sv': ->
                collection = new LibraryCollectionModel [],
                    realm: @model.id
                view = new LibraryCollection collection: collection
                collection.fetch()
                view
