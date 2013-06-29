define ["underscore", "views/proto/common", "views/user/big", "views/quest/dashboard-collection", "models/quest-collection", "models/current-user", "text!templates/dashboard.html"], (_, Common, UserBig, DashboardQuestCollection, QuestCollectionModel, currentUser, html) ->
    Common.extend
        template: _.template(html)
        activated: false
        activeMenuItem: ->
            (if @my() then "my-quests" else "none")

        tab: "open"
        realm: ->
            @options.realm

        events:
            "click ul.dashboard-nav a": "switchTab"

        subviews:
            ".user-subview": ->
                new UserBig(
                    model: @model
                    realm: @realm()
                )

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

        switchTab: (e) ->
            tab = $(e.target).closest("a").attr("data-dashboard-tab")
            @switchTabByName tab
            url = "/player/" + @model.get("login") + "/quest/" + tab
            Backbone.trigger "pp:navigate", url
            Backbone.trigger "pp:quiet-url-update"

        switchTabByName: (tab) ->
            @tab = tab
            @rebuildSubview ".quests-subview"
            @render() # TODO - why can't we just re-render a subview?

        createQuestSubview: (caption, options) ->
            that = this
            # open quests are always displayed in their entirety
            options.limit = 100  unless options.status is "open"
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
                    collection.add model,
                        prepend: true


                viewOptions.sortable = true
            collectionView = new DashboardQuestCollection(viewOptions)
            collectionView

        my: ->
            currentLogin = currentUser.get("login")
            return true  if currentLogin and currentLogin is @model.get("login")
            false

        tourGotQuest: ->
            @$(".newbie-tour-expect-quest").hide()
            @$(".newbie-tour-got-quest").show()
            mixpanel.track "first quest on tour"

        onTour: ->
            @my() and currentUser.onTour("profile")

        serialize: ->
            my = @my()
            tour = (my and currentUser.onTour("profile"))
            @listenToOnce Backbone, "pp:quest-add", @tourGotQuest  if tour
            my: my
            tour: tour

        afterRender: ->
            @$("[data-dashboard-tab=" + @tab + "]").parent().addClass "active"


