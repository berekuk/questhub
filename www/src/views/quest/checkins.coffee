define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "text!templates/quest/checkins.html"
], (_, Common, currentUser, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .quest-checkin-button": "checkin"

        checkin: -> @model.checkin()

        serialize: ->
            checkins: @model.get("checkins") or []
            enabled: "checkin" in (@model.get("tags") || [])
            isOwned: @model.isOwned()

        initialize: ->
            super
            @listenTo @model, "change:checkins", @render

        features: ['timeago']
