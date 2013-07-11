# move these into appropriate modules
require [
    "jquery",
    "routers/main", "routers/user", "routers/realm", "routers/quest", "routers/about", "routers/legacy"
    "views/app",
    "models/current-user",
    "bootstrap", "jquery.autosize", "jquery.timeago"
], ($, MainRouter, UserRouter, RealmRouter, QuestRouter, AboutRouter, LegacyRouter, App, currentUser) ->
    appView = new App(el: $("#wrap"))
    appView.render()
    $(document).ajaxError ->
        appView.notify "error", "Internal HTTP error"
        ga "send", "event", "server", "error"

    new MainRouter(appView)
    new RealmRouter(appView)
    new QuestRouter(appView)
    new UserRouter(appView)
    new AboutRouter(appView)
    new LegacyRouter(appView)

    Backbone.on "pp:notify", (type, message) ->
        appView.notify type, message

    Backbone.on "pp:settings-dialog", ->
        appView.settingsDialog()
        ga "send", "event", "settings", "open"

    currentUser.fetch success: ->

        # We're waiting for CurrentUser to be loaded before everything else.
        # It's a bit slower than starting the router immediately, but it prevents a few nasty race conditions.
        # Also, it's done just once, so all following navigation is actually *faster*.
        Backbone.history.start pushState: true


    # TODO - try to refetch user in a loop until backends goes online
    $(document).on "click", "a[href='#']", (event) ->
        event.preventDefault()  if not event.altKey and not event.ctrlKey and not event.metaKey and not event.shiftKey

    $(document).on "click", "a[href^='/']", (event) ->
        if not event.altKey and not event.ctrlKey and not event.metaKey and not event.shiftKey
            event.preventDefault()
            url = $(event.currentTarget).attr("href").replace(/^\//, "")
            Backbone.history.navigate url,
                trigger: true

    $(document).on "click", "a[href^='h']", (event) ->
        if not event.altKey and not event.ctrlKey and not event.metaKey and not event.shiftKey
            event.preventDefault()
            url = $(event.currentTarget).attr("href")
            window.open url, '_blank'
