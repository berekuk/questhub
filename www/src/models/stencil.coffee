define ["backbone"], (Backbone) ->
    class extends Backbone.Model
        idAttribute: "_id"
        urlRoot: "/api/stencil"

        take: ->
            mixpanel.track "take stencil"
            return $.post "#{ @url() }/take"
