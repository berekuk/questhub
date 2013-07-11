define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "views/stencil/big"
    "views/quest/collection", "models/quest-collection"
    "text!templates/stencil/page.html"
], (_, Common, currentUser, StencilBig, QuestCollection, QuestCollectionModel, html) ->
    class extends Common
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'

        subviews:
            ".stencil-big-sv": -> new StencilBig model: @model
            ".stencil-my-quests-sv": -> @questsSV @model.myQuests()
            ".stencil-quests-sv": -> @questsSV @model.otherQuests()


        questsSV: (quests) ->
            collection = new QuestCollectionModel(quests)
            view = new QuestCollection
                collection: collection
                showStatus: true
            view.noProgress()
            collection.gotMore = false
            view.updateShowMore()
            view

        events:
            "click ._take": ->
                @model.take success: =>
                    @rebuildSubview(".stencil-my-quests-sv")
                    @rebuildSubview(".stencil-quests-sv") # not expecting it to change, but why not, if we already got the updated data
                    @render()

        render: ->
            super
            @subview(".stencil-my-quests-sv").updateShowMore()
            @subview(".stencil-quests-sv").updateShowMore()

        serialize: -> @model.serialize()
