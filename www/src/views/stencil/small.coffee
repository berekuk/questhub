define [
    "underscore"
    "views/proto/common"
    "text!templates/stencil/small.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html

        events:
            "click ._take": "take"

        serialize: ->
            params = super
            params.relation = @relation || 'untaken'
            params

        take: ->
            @model.take()
            .success =>
                @relation = 'open'
                @render()
