define [
    "underscore"
    "views/proto/common"
    "text!templates/dashboard/profile/realm-collection.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
