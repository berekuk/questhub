define [
    "settings"
    "views/proto/common"
    "text!templates/realm/small.html"
], (settings, Common, html) ->
    class extends Common
        template: _.template(html)
