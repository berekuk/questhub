define [
    "underscore"
    "views/proto/common"
    "text!templates/dashboard/activity.html"
], (_, Common, html) ->
    class extends Common
        template: _.template(html)
