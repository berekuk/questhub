define [
    "underscore"
    "backbone"
    "routers/proto/common"
    "models/shared-models"
    "views/realm/page"
    "views/explore"
    "models/user-collection", "views/user/collection"
    "views/realm/detail-collection", "models/realm"
], (_, Backbone, Common, sharedModels, RealmPage, Explore, UserCollectionModel, UserCollection, RealmDetailCollection, RealmModel) ->
    class extends Common
        routes:
            "realms": "realms"
            "realm/:realm": "realmActivity"
            "realm/:realm/stencils": "realmStencils"
            "realm/:realm/stencils/tag/:tag": "realmStencils"
            "realm/:realm/players": "realmPlayers"
            "realm/:realm/explore(/:tab)": "realmExplore"
            "realm/:realm/explore/:tab/tag/:tag": "realmExplore"

        initialize: ->
            super
            @listenTo Backbone, "navigate:realm", (params) =>
                url = ''
                switch params.tab
                    when 'stencils' then url = '/stencils'
                    when 'activity' then url = ''
                    when 'players' then url = '/players'
                    when 'quests' then url = '/explore'
                    else throw "unknown tab"

                Backbone.history.navigate "/realm/#{params.realm}#{url}", trigger: true

        realms: ->
            view = new RealmDetailCollection collection: sharedModels.realms
            view.collection.fetch()
            @appView.setPageView view

        _realm: (realm, options) ->
            model = new RealmModel id: realm
            view = new RealmPage _.extend(
                { model: model },
                options
            )
            model.fetch()
                .success -> view.activate()
            @appView.setPageView view

        realmStencils: (realm, tag) ->
            @_realm realm,
                tab: 'stencils'
                stencils:
                    tag: tag

        realmActivity: (realm) ->
            @_realm realm, tab: 'activity'

        realmExplore: (realm, tab, tag) ->
            @_realm realm,
                tab: 'quests'
                explore:
                    tab: tab
                    tag: tag

        realmPlayers: (realm) ->
            @_realm realm, tab: 'players'
