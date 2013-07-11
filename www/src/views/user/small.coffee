define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "text!templates/user/small.html"
], (_, Common, currentUser, html) ->
    Common.extend
        template: _.template(html)
        tagName: "tr"
        serialize: ->
            params = @model.toJSON()
            params.currentUser = currentUser.get("login")
            params.realm = @options.realm
            params
