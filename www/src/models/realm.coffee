define [
    "backbone"
    "models/current-user"
], (Backbone, currentUser) ->
    class extends Backbone.Model
        url: -> "/api/realm/" + @get("id")

        serialize: ->
            params = @toJSON()
            login = currentUser.get "login"
            params.isKeeper = (login and params.keepers and login in params.keepers)
            params
