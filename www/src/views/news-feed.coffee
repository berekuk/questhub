define [
    "jquery", "underscore"
    "views/proto/common"
    "models/feed/collection", "views/feed/collection"
    "models/current-user"
    "text!templates/news-feed.html"
    "bootstrap"
], ($, _, Common, FeedCollectionModel, FeedCollection, currentUser, html) ->
    class extends Common
        template: _.template(html)
        className: "news-feed-view"
        activeMenuItem: "feed"
        subviews:
            ".subview": "eventCollection"

        eventCollection: ->
            collection = new FeedCollectionModel([],
                limit: 20
                for: @model.get("login")
            )
            collection.fetch()
            new FeedCollection collection: collection

        serialize: ->
            login: @model.get("login")
            tour: currentUser.onTour("feed")
            followingRealms: currentUser.get("fr")
            followingUsers: currentUser.get("fu")
