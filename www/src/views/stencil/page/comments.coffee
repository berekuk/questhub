define [
    "underscore"
    "views/proto/common"
    "text!templates/stencil/page/comments.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html
