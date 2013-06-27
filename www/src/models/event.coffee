define ["backbone"], (Backbone) ->
    Backbone.Model.extend
        idAttribute: "_id"
        name: ->
            @get "type"


