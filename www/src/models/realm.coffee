define ["backbone"], (Backbone) ->
    Backbone.Model.extend url: ->
        "/api/realm/" + @get("id")


