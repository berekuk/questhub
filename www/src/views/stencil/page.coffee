define [
    "underscore"
    "views/proto/tabbed"
    "models/shared-models"
    "views/realm/submenu"
    "views/stencil/big", "views/stencil/page/quests", "views/stencil/page/comments"
    "text!templates/stencil/page.html"
], (_, Tabbed, sharedModels, RealmSubmenu, StencilBig, StencilPageQuests, StencilPageComments, html) ->
    class extends Tabbed
        template: _.template html
        activated: false

        realm: -> @model.get 'realm'
        realmModel: -> sharedModels.realms.findWhere id: @realm()

        pageTitle: -> @model.get 'name'
        urlRoot: -> "/realm/#{@realm()}/stencil/#{ @model.id }"

        url: ->
            url = super
            if @tab == 'comments' and @options.anchor
                url += '/comment/' + @options.anchor
            url

        subviews: ->
            subviews = super
            subviews[".realm-submenu-sv"] = -> new RealmSubmenu model: @realmModel()
            subviews[".stencil-big-sv"] = ->
                new StencilBig
                    model: @model
                    tab: @tab
            subviews

        tab: 'comments'
        tabSubview: ".stencil-page-sv"
        tabs:
            quests:
                url: '/quests'
                subview: -> new StencilPageQuests model: @model
            comments:
                url: ''
                subview: ->
                    reply = @options.reply
                    delete @options.reply
                    new StencilPageComments
                        model: @model
                        reply: reply
                        anchor: @options.anchor

        initialize: ->
            super
            @listenTo @model, "change", =>
                @render() if @activated
                @trigger "change:page-title"

        initSubviews: ->
            super
            @listenTo @subview(".stencil-big-sv"), "switch", (params) ->
                @switchTabByName params.tab

        events:
            "click ._take": -> @model.take()

        serialize: ->
            params = super
            params.realmData = @realmModel().toJSON()
            params

        features: ["tooltip"]
