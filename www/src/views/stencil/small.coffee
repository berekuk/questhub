define [
    "underscore"
    "views/proto/common"
    "models/shared-models"
    "text!templates/stencil/small.html"
], (_, Common, sharedModels, html) ->
    class extends Common
        template: _.template html

        events:
            "click ._take": "take"

        take: ->
            @model.take()
            .success =>
                @model.fetch()
                .success =>
                    @render()

        serialize: ->
            params = super
            for quest in @model.get "quests"
                if sharedModels.currentUser.get("login") in quest.team
                    params.my = quest
                    break
            params
