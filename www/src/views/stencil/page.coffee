define [
    "underscore"
    "views/proto/common"
    "models/shared-models"
    "text!templates/stencil/page.html"
], (_, Common, sharedModels, html) ->
    class extends Common
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'

        # copy-pasted from views/stencil/small.coffee
        events:
            "click ._take": "take"

        serialize: ->
            params = super
            for quest in @model.get "quests"
                if sharedModels.currentUser.get("login") in quest.team
                    params.my = quest
                    break
            params

        take: ->
            @model.take()
            .success =>
                @model.fetch()
                .success =>
                    @render()
