define [
    "underscore"
    "views/proto/common"
    "views/quest/collection", "models/quest-collection"
    "raw!templates/stencil/page/quests.html"
], (_, Common, QuestCollection, QuestCollectionModel, html) ->
    class extends Common
        template: _.template html

        subviews:
            ".stencil-quests-sv": -> @questsSV @model.get("quests")

        questsSV: (quests) ->
            collection = new QuestCollectionModel(quests)
            view = new QuestCollection
                collection: collection
                showStatus: true
            view.noProgress()
            collection.gotMore = false
            view.updateShowMore()
            view

        initialize: ->
            super
            @listenTo @model, 'take:success', =>
                @rebuildSubview(".stencil-quests-sv")
                @render()

        render: ->
            super
            @subview(".stencil-quests-sv").updateShowMore()
