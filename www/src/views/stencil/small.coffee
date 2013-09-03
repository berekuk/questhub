define [
    "underscore"
    "views/proto/common"
    "views/helper/markdown"
    "text!templates/stencil/small.html"
], (_, Common, Markdown, html) ->
    class extends Common
        template: _.template html

        subviews:
            ".description-sv": ->
                new Markdown
                    realm: @model.get "realm"
                    text: @model.get "description"

        initialize: ->
            super
            @listenTo @model, "take:success", => @render()

        events:
            "click ._take": -> @model.take()

        features: ["tooltip"]
