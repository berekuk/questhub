define [
    "underscore"
    "views/proto/common"
], (_, Common) ->
    class extends Common

        tab: null # required
        tabSubview: null # required

        tabs: {} # required
        urlRoot: null # required

        initialize: ->
            @tab = @options.tab if @options.tab?
            super

        subviews: ->
            subviews = super
            subviews[@tabSubview] = =>
                method = @tabs[@tab].subview
                method = _.bind method, @
                method()
            subviews

        switchTabByName: (tab) ->
            @tab = tab
            @rebuildSubview(@tabSubview)
            url = _.result @, 'urlRoot'

            if @tabs[@tab].url?
                url += @tabs[@tab].url
            else if @tab2url
                url += @tab2url(@tab)
            else
                console.trace "one of tabs[tab].url or tab2url must be set"

            Backbone.history.navigate url
            Backbone.trigger "pp:quiet-url-update"
            @render()

        serialize: ->
            params = super
            params.tab = @tab
            params
