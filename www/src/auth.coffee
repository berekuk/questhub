define [
    "jquery"
    "models/current-user"
    "views/transitional"
    "backbone"
], ($, currentUser, Transitional, Backbone) ->
    # global backbone events for signing in and out

    personaWatch = false

    checkEmailConfirmed = ->
        if currentUser.get("registered")
            if currentUser.get("settings").email and not currentUser.get("settings").email_confirmed
                Backbone.trigger(
                    "pp:notify"
                    "warning"
                    """Your email address is not confirmed. Click the link we sent to #{ currentUser.get("settings").email } to confirm it.<br>(You can resend it from <a href="/settings">your settings</a> if necessary.)"""
                )
            else if currentUser.get("default_upic") and currentUser.get("age") > 30
                Backbone.trigger(
                    "pp:notify"
                    "warning"
                    """You don't have a profile picture yet. You can <a href="/settings">upload one from your settings</a>."""
                )

    checkUser = ->
        if currentUser.needsToRegister()
            Backbone.history.navigate "/register",
                trigger: true
                replace: true
            return

        checkEmailConfirmed()

    backendLogout = ->
        transitional = new Transitional message: 'Logging out...'

        $.post("/api/logout")
        .done =>
            window.location = "/"
        .fail =>
            Backbone.trigger "pp:notify", "error", "Logout failed."
            transitional.remove()

    logout = ->
        # TODO - show "Signing out..." view
        if currentUser.get("persona_user")
            navigator.id.logout() # will call backendLogout
        else
            backendLogout()

    setPersonaWatch = ->
        user = currentUser.get("persona_user")
        user = null unless user?

        navigator.id.watch
            loggedInUser: user
            onlogin: (assertion) =>
                transitional = new Transitional message: 'Signing in...'
                $.post "/auth/persona",
                    assertion: assertion
                .done =>
                    transitional.remove()
                    transitional = new Transitional message: "Checking your profile..."
                    currentUser.fetch()
                    .always ->
                        transitional.remove()
                .error =>
                    transitional.remove()
                    navigator.id.logout()
                    Backbone.trigger "pp:notify", "error", "/auth/persona failed."

            onlogout: =>
                backendLogout()
        personaWatch = true

    currentUser.on "sync change", setPersonaWatch
    currentUser.on "sync", checkUser

    Backbone.on "pp:login-with-persona": ->
        mixpanel.track "signin", how: "persona"
        # a precaution against "navigator.id.watch must be called before navigator.id.request" race condition
        # (I don't know how exactly this race happens, but I've seen it in the wild)
        setPersonaWatch() if not personaWatch
        navigator.id.request()

    Backbone.on "pp:login-with-twitter": ->
        # this may slow things down. oops.
        mixpanel.track "signin", how: "twitter", ->
            window.location = '/auth/twitter'

        # so we're setting a timeout in case mixpanel.track falls off track
        window.setTimeout ->
            window.location = '/auth/twitter'
        , 300

    Backbone.on "pp:logout": -> logout()
