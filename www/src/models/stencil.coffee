define [
    "underscore", "backbone"
    "models/current-user"
], (_, Backbone, currentUser) ->
    class extends Backbone.Model
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
            console.log allMyQuests
            if _.findWhere allMyQuests, { status: "open" }
                params.myStatus = "open"
            else if _.findWhere allMyQuests, { status: "closed" }
                params.myStatus = "closed"
            else
                params.myStatus = "none"
            console.log params.myStatus
            params.otherQuests = @otherQuests()
            params.currentUser = currentUser.get "login"
            params
