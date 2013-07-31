define [
    "underscore"
    "views/proto/common"
    "text!templates/stencil/small.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html

        initialize: ->
            super
            @listenTo @model, "take:success", => @render()

        events:
            "click ._take": -> @model.take()

        features: ["tooltip"]
