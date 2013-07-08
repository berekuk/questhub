define [
    "underscore"
    "views/proto/common"
    "views/realm/big"
    "views/explore"
    "views/realm/page/activity"
    "views/user/collection", "models/user-collection"
    "text!templates/realm-page.html"
], (_, Common, RealmBig, Explore, RealmPageActivity, UserCollection, UserCollectionModel, html) ->
    class extends Common
        template: _.template(html)
        activeMenuItem: "realm-page"
        activated: false

        initialize: ->
            @tab = @options.tab || 'activity'
            super

        subviews:
            ".realm-big-sv": ->
                new RealmBig
                    model: @model
                    tab: @tab
            ".realm-page-sv": ->
                if @tab == 'quests'
                    sv = new Explore _.extend(
                        { realm: @model.get('id') },
                        @options.explore || {}
                    )
                    sv.activate()
                    sv
                else if @tab == 'activity'
                    new RealmPageActivity model: @model
                else if @tab == 'players'
                    collection = new UserCollectionModel [],
                        realm: @model.get('id')
                        sort: "leaderboard"
                        limit: 100
                    view = new UserCollection collection: collection
                    collection.fetch()
                    view
                else
                    alert "unknown tab #{@tab}"

        realm: ->
            @model.get "id"

        initSubviews: ->
            super
            @listenTo @subview(".realm-big-sv"), "switch", (params) ->
                tab = params.tab
                @switchTabByName tab
                tab2url =
                    quests: '/explore'
                    activity: ''
                    players: '/players'
                Backbone.history.navigate "/realm/#{ @model.get("id") }#{ tab2url[tab] }"
                Backbone.trigger "pp:quiet-url-update"

        switchTabByName: (tab) ->
            @tab = tab
            @rebuildSubview(".realm-page-sv").render()
