define [
    "jquery", "underscore"
    "views/proto/tabbed"
    "models/event-collection", "views/event/collection"
    "models/feed/collection", "views/feed/collection"
    "models/current-user"
    "text!templates/news-feed.html"
    "bootstrap"
], ($, _, Tabbed, EventCollectionModel, EventCollection, FeedCollectionModel, FeedCollection, currentUser, html) ->
    class extends Tabbed
        template: _.template(html)
        activeMenuItem: "feed"

        events:
            "click ul.news-feed-tabs a": "switchTab"

        tab: 'grouped'
        tabSubview: '.news-feed-sv'
        urlRoot: -> "/"
        tabs:
            grouped:
                url: ''
                subview: ->
                    collection = new FeedCollectionModel([],
                        limit: 20
                        for: @model.get("login")
                    )
                    collection.fetch()
                    new FeedCollection collection: collection

        switchTab: (e) ->
            return if e.ctrlKey or e.metaKey # link clicked and will be opened in new tab
            e.preventDefault()
            @switchTabByName $(e.target).closest("a").attr("data-tab")

        serialize: ->
            login: @model.get("login")
            tour: currentUser.onTour("feed")
            followingRealms: currentUser.get("fr")
            followingUsers: currentUser.get("fu")

        render: ->
            super
            @$(".news-feed-tabs [data-tab=" + @tab + "]").parent().addClass "active"

        features: ["tooltip"]
