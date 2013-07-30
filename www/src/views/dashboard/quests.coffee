define [
    "underscore"
    "views/proto/tabbed"
    "views/quest/dashboard-collection", "models/quest-collection"
    "models/current-user"
    "text!templates/dashboard/quests.html"
], (_, Tabbed, DashboardQuestCollection, QuestCollectionModel, currentUser, html) ->
    class extends Tabbed
        template: _.template(html)

        events:
            "click ul.dashboard-quests-tabs a": "switchTab"

        urlRoot: -> "/player/#{ @model.get("login") }"
        tab: "open"
        tabSubview: ".quests-subview"
        tabs:
            open:
                url: ''
                subview: ->
                    @createQuestSubview "open",
                        sort: "manual"
                        status: "open"
            closed:
                url: '/quest/closed'
                subview: ->
                    @createQuestSubview "completed",
                        status: "closed"
            abandoned:
                url: '/quest/abandoned'
                subview: ->
                    @createQuestSubview "abandoned",
                        status: "abandoned"

        switchTab: (e) -> @switchTabByName $(e.target).closest("a").attr("data-tab")

        createQuestSubview: (caption, options) ->
            # open quests are always displayed in their entirety
            options.limit = 100 unless options.status is "open"
            options.order = "desc"
            options.user = @model.get("login")
            collection = new QuestCollectionModel([], options)
            collection.fetch()
            viewOptions =
                collection: collection
                caption: caption
                user: @model.get("login")

            if options.status is "open" and @my()
                @listenTo Backbone, "pp:quest-add", (model) ->
                    collection.add model, prepend: true
                viewOptions.sortable = true

            collectionView = new DashboardQuestCollection(viewOptions)
            collectionView

        my: ->
            currentLogin = currentUser.get("login")
            return true if currentLogin and currentLogin is @model.get("login")
            false

        render: ->
            super
            @$(".dashboard-quests-tabs [data-tab=" + @tab + "]").parent().addClass "active"
