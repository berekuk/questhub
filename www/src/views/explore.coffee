define [
    "jquery", "underscore"
    "backbone"
    "views/proto/tabbed"
    "models/quest-collection", "views/quest/collection"
    "models/current-user"
    "raw!templates/explore.html"
], ($, _, Backbone, Tabbed, QuestCollectionModel, QuestCollection, currentUser, html) ->
    class extends Tabbed
        template: _.template html
        className: "explore"

        events:
            "click ul.explore-nav a": "switchTab"
            "click .remove-filter": "removeFilter"

        initialize: (options) ->
            @tag = options.tag
            super

        tab: "latest"
        tabSubview: ".explore-tab-content"
        urlRoot: -> "/realm/#{@realm()}/explore"

        realm: -> @options.realm

        tabs:
            latest:
                subview: ->
                    @createSubview
                        order: "desc"
                        showStatus: true
            unclaimed:
                subview: ->
                    @createSubview
                        unclaimed: 1
                        sort: "leaderboard"
            open:
                subview: ->
                    @createSubview
                        status: "open"
                        sort: "leaderboard"
            closed:
                subview: ->
                    @createSubview
                        status: "closed"
                        sort: "leaderboard"
            "watched-by-me":
                subview: ->
                    @createSubview
                        order: "desc"
                        watchedByMe: true
                        showStatus: true

        tab2url: (tab) ->
            url = "/#{tab}"
            url += "/tag/#{@tag}" if @tag?
            url

        createSubview: (options) ->
            options.limit = 100
            options.realm = @realm()
            options.tags = @tag if @tag?
            if options.watchedByMe
                unless currentUser.get("login")
                    Backbone.history.navigate "/welcome",
                        trigger: true
                        replace: true

                    # fake empty collection, just to get us going until navigate event is processed
                    return new QuestCollection(collection: new QuestCollection())
                options.watchers = currentUser.get("login")

            collection = new QuestCollectionModel [], options
            collection.fetch()
            new QuestCollection
                collection: collection
                showStatus: options.showStatus

        switchTab: (e) ->
            return if e.ctrlKey or e.metaKey
            e.preventDefault()

            @switchTabByName $(e.target).attr("data-explore-tab")

        serialize: ->
            tag: @tag
            currentUser: currentUser.get("login")
            realm: @realm()

        render: ->
            super
            @$("[data-explore-tab=" + @tab + "]").parent().addClass "active"

        removeFilter: ->
            Backbone.history.navigate "/realm/#{ @realm() }/explore/#{@tab}",
                trigger: true
