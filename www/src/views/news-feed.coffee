define ["jquery", "underscore", "views/proto/common", "models/event-collection", "views/event/collection", "models/current-user", "text!templates/news-feed.html", "bootstrap"], ($, _, Common, EventCollectionModel, EventCollection, currentUser, html) ->
    Common.extend
        template: _.template(html)
        className: "news-feed-view"
        activeMenuItem: "feed"
        subviews:
            ".subview": "eventCollection"

        eventCollection: ->
            collection = new EventCollectionModel([],
                limit: 50
                for: @model.get("login")
            )
            collection.fetch()
            new EventCollection(
                collection: collection
                showRealm: true
            )

        serialize: ->
            login: @model.get("login")
            tour: currentUser.onTour("feed")
            followingRealms: currentUser.get("fr")
            followingUsers: currentUser.get("fu")
