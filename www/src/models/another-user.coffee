define ["backbone", "models/user"], (Backbone, User) ->
    User.extend
        initialize: ->

        url: -> "/api/user/" + @get("login")
