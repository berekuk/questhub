define ["views/proto/common", "models/current-user", "text!templates/realm-controls.html"], (Common, currentUser, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .realm-follow": "follow"
            "click .realm-unfollow": "unfollow"

        follow: ->
            that = this
            currentUser.followRealm(@model.get("id")).always ->
                currentUser.fetch().done ->
                    that.render()


        unfollow: ->
            that = this
            currentUser.unfollowRealm(@model.get("id")).always ->
                currentUser.fetch().done ->
                    that.render()


        serialize: ->
            params = @model.toJSON()
            params.currentUser = currentUser
            params
