define [
    "underscore"
    "views/proto/common"
    "text!templates/stencil/page.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'

        events:
            "click ._take": "take"

        take: ->
            @model.take()
