define [
    "underscore"
    "views/proto/common"
    "text!templates/not-found.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
        selfRender: true
        activeMenuItem: "none"
