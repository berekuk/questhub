define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "raw!templates/user/small.html"
], (_, Common, currentUser, html) ->
    class extends Common
        template: _.template(html)
        tagName: "tr"
        serialize: ->
            params = super
            params.currentUser = currentUser.get("login")
            params.realm = @options.realm
            params
