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
                options = realm: @model.id
                options.tags = @options.tag if @options.tag?
                collection = new CollectionModel [], options

                view = new Collection collection: collection
                collection.fetch()
                @setCollection collection
                view

        setCollection: (collection) ->
            @collection = collection
            @listenTo @collection, "reset sync", @render

        addDialog: ->
            new StencilAdd realm: @model.id

        serialize: ->
            params = super
            params.currentUser = sharedModels.currentUser.get "login"
            params.isKeeper = (params.currentUser && @model.get("keepers") && _.contains(@model.get("keepers"), params.currentUser))
            params.tags = @collection?.allTags()
            params.activeTag = @options.tag
            params

        features: ["tooltip"]
