define [
  "views/proto/common"
  "text!templates/realm/tabs.html"
], (Common, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click ._icon": "switch"

        initialize: ->
            @tab = @options.tab
            super

        switch: (e) ->
            return if e.ctrlKey or e.metaKey # link clicked and will be opened in new tab
            e.preventDefault()

            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            if @options.navigate
                Backbone.trigger "navigate:realm", realm: @model.get("id"), tab: @tab
            else
                @trigger "switch", tab: @tab
                t.closest("ul").find("._active").removeClass "_active"
                t.addClass "_active"

        serialize: ->
            id: @model.get("id")
            small: @options.small
            current_tab: @tab

        features: ["tooltip"]
