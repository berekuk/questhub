define [
    "underscore"
    "views/proto/common"
    "text!templates/library/quest-small.html"
], (_, Common, html) ->
    class extends Common
        template: _.template html
