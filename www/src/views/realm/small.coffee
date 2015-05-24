define [
    "underscore"
    "settings"
    "views/proto/common"
    "raw!templates/realm/small.html"
], (_, settings, Common, html) ->
    class extends Common
        template: _.template(html)
