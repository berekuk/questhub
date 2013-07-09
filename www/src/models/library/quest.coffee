define ["backbone"], (Backbone) ->
    class extends Backbone.Model
        idAttribute: "_id"
        urlRoot: "/api/library"
