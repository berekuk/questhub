define [
    "underscore"
    "views/proto/common"
    "models/user-collection", "views/user/collection"
    "text!templates/realm/page/players.html"
], (_, Common, UserCollectionModel, UserCollection, html) ->
    class extends Common
        template: _.template(html)

        subviews:
            ".user-collection-sv": ->
                collection = new UserCollectionModel [],
                    realm: @model.get('id')
                    sort: "leaderboard"
                    limit: 100
                view = new UserCollection collection: collection
                collection.fetch()
                view
