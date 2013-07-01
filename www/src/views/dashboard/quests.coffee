define [
    "underscore"
    "views/proto/common"
    "views/quest/dashboard-collection", "models/quest-collection"
    "models/current-user"
    "text!templates/dashboard/quests.html"
], (_, Common, DashboardQuestCollection, QuestCollectionModel, currentUser, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click ul.dashboard-quests-tabs a": "switchTab"

        initialize: ->
            @tab = @options.tab || 'open'
            super

        subviews:
            ".quests-subview": ->
                if @tab is "open"
                    @createQuestSubview "open",
                        sort: "manual"
                        status: "open"

                else if @tab is "closed"
                    @createQuestSubview "completed",
                        status: "closed"

                else if @tab is "abandoned"
                    @createQuestSubview "abandoned",
                        status: "abandoned"

                else
                    Backbone.trigger "pp:notify", "error", "unknown tab " + @tab

        createQuestSubview: (caption, options) ->
            that = this
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

        switchTab: (e) ->
            tab = $(e.target).closest("a").attr("data-tab")
            @switchTabByName tab
            url = "/player/#{ @model.get("login") }/quest/#{tab}"
            Backbone.history.navigate url
            Backbone.trigger "pp:quiet-url-update"

        switchTabByName: (tab) ->
            @tab = tab
            @rebuildSubview ".quests-subview"
            @render() # TODO - why can't we just re-render a subview?

        my: ->
            currentLogin = currentUser.get("login")
            return true if currentLogin and currentLogin is @model.get("login")
            false

        afterRender: ->
            @$(".dashboard-quests-tabs [data-tab=" + @tab + "]").parent().addClass "active"
