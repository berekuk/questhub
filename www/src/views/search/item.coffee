define [
    "underscore"
    "views/proto/common"
    "views/quest/feed"
    "models/quest"
    "text!templates/search/item.html"
], (_, Common, QuestBig, QuestModel, html) ->
    class extends Common
        template: _.template html

        subviews:
            ".quest-sv": ->
                new QuestBig model: new QuestModel(@model.toJSON())
