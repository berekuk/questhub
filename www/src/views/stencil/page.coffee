define [
    "underscore"
    "views/proto/common"
    "models/current-user", "models/shared-models"
    "views/realm/submenu"
    "views/stencil/big"
    "views/quest/collection", "models/quest-collection"
    "text!templates/stencil/page.html"
], (_, Common, currentUser, sharedModels, RealmSubmenu, StencilBig, QuestCollection, QuestCollectionModel, html) ->
    class extends Common
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'
        realmModel: -> sharedModels.realms.findWhere id: @realm()

        pageTitle: -> @model.get 'name'

        subviews:
            ".realm-submenu-sv": -> new RealmSubmenu model: @realmModel()
            ".stencil-big-sv": -> new StencilBig model: @model
            ".stencil-my-quests-sv": -> @questsSV @model.myQuests()
            ".stencil-quests-sv": -> @questsSV @model.otherQuests()

        initialize: ->
            super
            @listenTo @model, "change", =>
                @render() if @activated
                @trigger "change:page-title"

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

        serialize: ->
            params = super
            params.realmData = @realmModel().toJSON()
            params

        features: ["tooltip"]
