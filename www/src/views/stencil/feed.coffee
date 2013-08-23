define [
    "underscore"
    "views/stencil/big"
    "models/shared-models"
    "text!templates/stencil/feed.html"
], (_, StencilBig, sharedModels, html) ->
    class extends StencilBig
        template: _.template(html)

        events: ->
            events = StencilBig::events
            events["click .js-stencil-take"] = -> @model.take()
            events

        initialize: ->
            super
            @listenTo @model, "take:success", => @render()

        serialize: ->
            params = super
            params.realmData = sharedModels.realms.findWhere(id: @model.get("realm")).toJSON()
            params
