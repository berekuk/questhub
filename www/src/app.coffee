# move these into appropriate modules
require [
    "jquery",
    "routers/main", "routers/user", "routers/realm", "routers/quest", "routers/about", "routers/legacy", "routers/not-found", "routers/search"
    "views/app",
    "models/current-user",
    "views/helper/textarea"
    "bootstrap", "jquery.autosize", "jquery.timeago", "jquery.easing"
], ($, MainRouter, UserRouter, RealmRouter, QuestRouter, AboutRouter, LegacyRouter, NotFoundRouter, SearchRouter, App, currentUser, TextArea) ->
    appView = new App(el: $("#wrap"))
    appView.render()
    $(document).ajaxError ->
        appView.notify "error", "Internal HTTP error"
        ga "send", "event", "server", "error"

    new NotFoundRouter(appView)
    new MainRouter(appView)
    new RealmRouter(appView)
    new QuestRouter(appView)
    new UserRouter(appView)
    new AboutRouter(appView)
    new SearchRouter(appView)
    new LegacyRouter(appView)

    Backbone.on "pp:notify", (type, message) ->
        appView.notify type, message

    Backbone.on "pp:settings-dialog", ->
        appView.settingsDialog()
        ga "send", "event", "settings", "open"

    # TODO - try to refetch user in a loop until backends goes online
    currentUser.fetch success: ->
        # We're waiting for CurrentUser to be loaded before everything else.
        # It's a bit slower than starting the router immediately, but it prevents a few nasty race conditions.
        # Also, it's done just once, so all following navigation is actually *faster*.
        Backbone.history.start pushState: true

    window.onbeforeunload = ->
        if TextArea.active()
            return "You haven't finished editing yet."
        return

    $(document).on "click", "a[href='#']", (event) ->
        return if event.altKey or event.ctrlKey or event.metaKey or event.shiftKey
        event.preventDefault()

    $(document).on "click", "a[href^='/']", (event) ->
        return if event.altKey or event.ctrlKey or event.metaKey or event.shiftKey
        return if TextArea.active() # not calling preventDefault, so we'll do a full page reload
        el = $(event.currentTarget)
        return if el.attr("target") == "_blank"

        event.preventDefault()
        fragment = el.attr("href").replace(/^\//, "")
        if Backbone.history.fragment == fragment
            # Backbone won't reload the page if we navigate to the current fragment
            # so we have to mess with its internals
            Backbone.history.loadUrl fragment
        else
            Backbone.history.navigate fragment, trigger: true

    $(document).on "click", "a[href^='h']", (event) ->
        return if event.altKey or event.ctrlKey or event.metaKey or event.shiftKey
        event.preventDefault()
        url = $(event.currentTarget).attr("href")
        window.open url, '_blank'
