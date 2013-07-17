define [
  "views/proto/common"
  "views/realm/controls"
  "text!templates/realm/big.html"
], (Common, RealmControls, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .realm-big-tabs div._icon": "switch"

        subviews:
            ".controls-subview": ->
                new RealmControls model: @model

        initialize: ->
            @tab = @options.tab || 'stencils'
            super

        switch: (e) ->
            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            @trigger "switch", tab: @tab
            t.closest("ul").find("._active").removeClass "_active"
            t.addClass "_active"

        serialize: ->
            params = @model.toJSON()
            params.tab = @tab
            params

        features: ["tooltip"]
