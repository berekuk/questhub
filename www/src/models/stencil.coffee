define [
    "backbone"
    "models/current-user"
], (Backbone, currentUser) ->
    class extends Backbone.Model
        idAttribute: "_id"
        urlRoot: "/api/stencil"

        take: ->
            mixpanel.track "take stencil"
            $.post("#{ @url() }/take")
            .success => @fetch()

        serialize: ->
            params = @toJSON()
            for quest in @get "quests"
                if currentUser.get("login") in quest.team
                    params.my = quest
                    break
            params.currentUser = currentUser.get "login"
            params
