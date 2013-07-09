define [
    "underscore"
    "views/proto/tabbed"
    "views/realm/big"
    "views/explore"
    "views/realm/page/library", "views/realm/page/activity"
    "views/user/collection", "models/user-collection"
    "text!templates/realm-page.html"
], (_, Tabbed, RealmBig, Explore, RealmPageLibrary, RealmPageActivity, UserCollection, UserCollectionModel, html) ->
    class extends Tabbed
        template: _.template(html)
        activeMenuItem: "realm-page"
        activated: false

        realm: -> @model.get "id"

        urlRoot: -> "/realm/#{ @model.get("id") }"
        tab: 'library'
        tabSubview: ".realm-page-sv"
        tabs:
            library:
                url: ''
                subview: -> new RealmPageLibrary model: @model
            activity:
                url: '/activity'
                subview: -> new RealmPageActivity model: @model
            quests:
                url: '/explore'
                subview: ->
                    sv = new Explore _.extend(
                        { realm: @model.get('id') },
                        @options.explore || {}
                    )
                    sv.activate()
                    sv
            players:
                url: '/players'
                subview: ->
                    collection = new UserCollectionModel [],
                        realm: @model.get('id')
                        sort: "leaderboard"
                        limit: 100
                    view = new UserCollection collection: collection
                    collection.fetch()
                    view


        subviews: ->
            subviews = super
            subviews[".realm-big-sv"] = ->
                new RealmBig
                    model: @model
                    tab: @tab
            subviews


        initSubviews: ->
            super
            @listenTo @subview(".realm-big-sv"), "switch", (params) ->
                @switchTabByName params.tab
