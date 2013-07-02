define ["backbone"], (Backbone) ->
    Backbone.Model.extend
        initialize: -> alert "trying to instantiate abstract base class"

        loadStat: ->
            $.getJSON "/api/user/#{ @get("login") }/stat", (data) =>
                @set 'stat', data
