define [
    "underscore"
    "views/proto/common"
    "text!templates/stencil/big.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html
        serialize: -> @model.serialize()
        features: ["timeago"]
