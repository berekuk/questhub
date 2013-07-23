define [
    "underscore"
    "views/proto/common"
    "text!templates/quest/add/realm-helper.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
