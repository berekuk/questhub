define [
    "underscore"
    "views/proto/common"
    "raw!templates/not-found.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
        selfRender: true
        activeMenuItem: "none"
