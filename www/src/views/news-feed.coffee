define [
    "jquery", "underscore"
    "views/proto/tabbed"
    "models/event-collection", "views/event/collection"
    "models/feed/collection", "views/feed/collection"
    "models/current-user"
    "text!templates/news-feed.html"
    "bootstrap"
], ($, _, Tabbed, EventCollectionModel, EventCollection, FeedCollectionModel, FeedCollection, currentUser, html) ->
    tabs = ["default", "users", "realms", "watched", "global"]

    class extends Tabbed
        template: _.template(html)
        activeMenuItem: "feed"

        events:
            "click ul.news-feed-tabs a": "switchTab"

        tab: 'default'
        tabSubview: '.news-feed-sv'
        urlRoot: -> "/"

        tabs: _.object tabs, _.map tabs, (t) ->
            url: ''
            subview: ->
                collection = new FeedCollectionModel([],
                    limit: 20
                    for: @model.get("login")
                    tab: t
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
            tab: @tab

        render: ->
            super
            @$(".news-feed-tabs [data-tab=" + @tab + "]").parent().addClass "active"

        features: ["tooltip"]
