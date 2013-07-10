define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "text!templates/quest/completed.html"
], (_, Common, currentUser, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .btn-primary": "stop"

        initialize: ->
            super
            @setElement $("#quest-completed-modal")

        start: ->
            @render()
            @$(".modal").modal "show"
            $.getScript "http://platform.twitter.com/widgets.js"

        stop: ->
            @$(".modal").modal "hide"

        serialize: ->
            params = @model.serialize()
            params.gotTwitter = Boolean(currentUser.get("twitter"))
            params.totalPoints = params.reward + (currentUser.get("rp")[@model.get("realm")] || 0)
            params
