define [
    "jquery", "underscore"
    "models/proto/post"
    "models/current-user"
], ($, _, Post, currentUser) ->
    class extends Post
        idAttribute: "_id"
        urlRoot: "/api/stencil"

        take: ->
            mixpanel.track "take stencil"
            $.post("#{ @url() }/take")
            .success =>
                @fetch().success => @trigger "take:success"

        myQuests: ->
            _.filter(
                @get("quests"),
                (q) -> q.author == currentUser.get("login") and q.status == 'open'
            )

        otherQuests: ->
            _.filter(
                @get("quests"),
                (q) -> q.author != currentUser.get("login") or q.status != 'open'
            )

        serialize: ->
            params = @toJSON()
            params.myQuests = @myQuests()

            allMyQuests = _.where @get("quests"), { author: currentUser.get("login") }
            if _.findWhere allMyQuests, { status: "open" }
                params.myStatus = "open"
            else if _.findWhere allMyQuests, { status: "closed" }
                params.myStatus = "closed"
            else
                params.myStatus = "none"
            params.otherQuests = @otherQuests()
            params.currentUser = currentUser.get "login"
            params
