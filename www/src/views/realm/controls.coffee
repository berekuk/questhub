define [
    "views/proto/common"
    "models/current-user"
    "text!templates/realm/controls.html"
], (Common, currentUser, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .realm-follow": "follow"
            "click .realm-unfollow": "unfollow"

        initialize: ->
            super
            @listenTo currentUser, 'change', @render

        follow: -> currentUser.followRealm @model.get("id")
        unfollow: -> currentUser.unfollowRealm @model.get("id")

        serialize: ->
            params = @model.toJSON()
            params.currentUser = currentUser
            params
