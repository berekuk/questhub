define ["backbone", "underscore", "markdown", "settings", "views/partials"], (Backbone, _, markdown, settings, partials) ->
    Backbone.View.extend
        partial: partials
        initialize: ->
            @listenTo Backbone, "pp:logviews", ->
                console.log this



