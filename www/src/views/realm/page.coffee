define [
    "underscore"
    "views/proto/tabbed"
    "views/realm/big"
    "views/explore", "views/stencil/overview", "views/realm/page/activity", "views/realm/page/players"
    "text!templates/realm/page.html"
], (_, Tabbed, RealmBig, Explore, RealmPageStencils, RealmPageActivity, RealmPagePlayers, html) ->
    class extends Tabbed
        template: _.template(html)
        activeMenuItem: "realm-page"
        activated: false

        pageTitle: -> @model.get "name"

        realm: -> @model.get "id"

        urlRoot: -> "/realm/#{ @model.get("id") }"
        tab: 'activity'
        tabSubview: ".realm-page-sv"
        tabs:
            stencils:
                url: '/stencils'
                subview: -> new RealmPageStencils model: @model
            activity:
                url: ''
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
                subview: -> new RealmPagePlayers model: @model

        initialize: ->
            super
            @listenTo @model, "change", => @trigger "change:page-title"

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
