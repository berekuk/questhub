define [
    "backbone"
], (Backbone) ->
    class extends Backbone.Router
        initialize: (appView) ->
            @appView = appView
            @bind "route", @_trackPageview

        _trackPageview: ->
            url = Backbone.history.getFragment()
            url = "/" + url

            ga "send", "pageview", page: url
            mixpanel.track_pageview url

        # unused, but may be useful in future
        queryParams: (name) ->
            name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
            regexS = "[\\?&]" + name + "=([^&#]*)"
            regex = new RegExp(regexS)
            results = regex.exec(window.location.search)
            unless results?
                ""
            else
                decodeURIComponent results[1].replace(/\+/g, " ")
