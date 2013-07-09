define [
    "underscore"
    "views/proto/common"
    "text!templates/realm-page/library.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
