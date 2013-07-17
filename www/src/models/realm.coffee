define [
    "backbone"
    "models/current-user"
], (Backbone, currentUser) ->
    class extends Backbone.Model
        url: -> "/api/realm/" + @get("id")

        isKeeper: ->
            login = currentUser.get "login"
            return (login and @get("keepers") and login in @get("keepers"))

        serialize: ->
            params = @toJSON()
            login = currentUser.get "login"
            params.isKeeper = @isKeeper()
            params
