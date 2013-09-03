define ["backbone", "underscore", "views/partials"], (Backbone, _, partials) ->
    class extends Backbone.View
        partial: partials
        initialize: ->
            @listenTo Backbone, "pp:logviews", ->
                console.log this
