define ["backbone", "settings"], (Backbone, settings) ->
    Backbone.Collection.extend url: "/api/realm"

