define [
    "underscore"
    "views/quest/big"
    "models/shared-models"
    "text!templates/quest/feed.html"
], (_, QuestBig, sharedModels, html) ->
    class extends QuestBig
        template: _.template(html)

        serialize: ->
            params = super
            params.showStatus = false
            params.realmData = sharedModels.realms.findWhere(id: @model.get("realm")).toJSON()
            params
