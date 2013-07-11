define [
    "underscore"
    "views/proto/common"
    "models/shared-models"
    "models/stencil/collection", "views/stencil/collection"
    "views/stencil/add"
    "text!templates/stencil/overview.html"
], (_, Common, sharedModels, CollectionModel, Collection, StencilAdd, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .add-stencil": "addDialog"

        subviews:
            '.stencil-collection-sv': ->
                collection = new CollectionModel [],
                    realm: @model.id
                view = new Collection collection: collection
                collection.fetch()
                view

        addDialog: ->
            new StencilAdd realm: @model.id

        serialize: ->
            params = super
            params.currentUser = sharedModels.currentUser.get "login"
            params.isKeeper = (params.currentUser && @model.get("keepers") && _.contains(@model.get("keepers"), params.currentUser))
            params
