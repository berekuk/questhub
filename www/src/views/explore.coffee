define ["underscore", "views/proto/common", "models/quest-collection", "views/quest/collection", "models/current-user", "text!templates/explore.html"], (_, Common, QuestCollectionModel, QuestCollection, currentUser, html) ->
    Common.extend
        template: _.template(html)
        activeMenuItem: "explore"
        className: "explore"
        events:
            "click ul.explore-nav a": "switchTab"
            "click .remove-filter": "removeFilter"

        subviews:
            ".explore-tab-content": "tabSubview"

        tab: "latest"
        activated: false
        afterInitialize: ->
            _.bindAll this

        name2options:
            latest:
                order: "desc"
                showStatus: true

            unclaimed:
                unclaimed: 1
                sort: "leaderboard"

            open:
                status: "open"
                sort: "leaderboard"

            closed:
                status: "closed"
                sort: "leaderboard"

            "watched-by-me":
                order: "desc"
                watchedByMe: true
                showStatus: true

        realm: ->
            @options.realm

        tabSubview: ->
            options = _.clone(@name2options[@tab])
            options.realm = @realm()
            if options.watchedByMe
                unless currentUser.get("login")
                    Backbone.trigger "pp:navigate", "/welcome",
                        trigger: true
                        replace: true


                    # fake empty collection, just to get us going until navigate event is processed
                    return new QuestCollection(collection: new QuestCollection())
                options.watchers = currentUser.get("login")
            options.tags = @tag if @tag?
            @createSubview options

        createSubview: (options) ->
            options.limit = 100
            collection = new QuestCollectionModel([], options)
            collection.fetch()
            new QuestCollection(
                collection: collection
                showStatus: options.showStatus
            )

        switchTab: (e) ->
            tab = $(e.target).attr("data-explore-tab")
            @switchTabByName tab
            url = "/realm/#{@realm()}/explore/#{tab}"
            url += "/tag/#{@tag}" if @tag?
            Backbone.trigger "pp:navigate", url
            Backbone.trigger "pp:quiet-url-update"

        switchTabByName: (tab) ->
            @tab = tab
            @initSubviews() # recreate tab subview
            @render()

        serialize: ->
            tag: @tag
            currentUser: currentUser.get("login")

        afterRender: ->
            @$("[data-explore-tab=" + @tab + "]").parent().addClass "active"

        removeFilter: ->
            Backbone.trigger "pp:navigate", "/realm/" + @realm() + "/explore/" + @tab,
                trigger: true
