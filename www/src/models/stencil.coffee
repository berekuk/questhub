define [
    "underscore", "backbone"
    "models/current-user"
], (_, Backbone, currentUser) ->
    class extends Backbone.Model
        idAttribute: "_id"
        urlRoot: "/api/stencil"

        take: ({ success } = {})->
            mixpanel.track "take stencil"
            $.post("#{ @url() }/take")
            .success =>
                console.log "posted"
                @fetch().success =>
                    console.log "fetched"
                    success()

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
            params.otherQuests = @otherQuests()
            params.currentUser = currentUser.get "login"
            params
