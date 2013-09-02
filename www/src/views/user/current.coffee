define [
    "backbone", "underscore"
    "views/proto/common"
    "views/user/notifications-box"
    "models/current-user"
    "views/transitional"
    "text!templates/current-user.html"
], (Backbone, _, Common, NotificationsBox, currentUser, Transitional, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .logout": "logout"
            "click .login-with-persona": "loginWithPersona"
            "click .login-with-twitter": "loginWithTwitter"
            "click .notifications": "notificationsDialog"

        loginWithPersona: ->
            mixpanel.track "signin", how: "persona"

            # a precaution against "navigator.id.watch must be called before navigator.id.request" race condition
            # (I don't know how exactly this race happens, but I've seen it in the wild)
            @setPersonaWatch() if not @personaWatch

            navigator.id.request()

        loginWithTwitter: ->
            # this may slow things down. oops.
            mixpanel.track "signin", how: "twitter", ->
                window.location = '/auth/twitter'

            # so we're setting a timeout in case mixpanel.track falls off track
            window.setTimeout ->
                window.location = '/auth/twitter'
            , 300

        notificationsDialog: ->
            @_notificationsBox = new NotificationsBox(model: @model)  unless @_notificationsBox
            @_notificationsBox.start()

        setPersonaWatch: ->
            user = @model.get("persona_user")
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
                        @model.fetch()
                        .always ->
                            transitional.remove()
                    .error =>
                        transitional.remove()
                        navigator.id.logout()
                        Backbone.trigger "pp:notify", "error", "/auth/persona failed."

                onlogout: =>
                    @backendLogout()
            @personaWatch = true


        initialize: ->
            super
            @listenTo @model, "sync change", @setPersonaWatch
            @listenTo @model, "sync", @checkUser
            @listenTo @model, "change", @render
            @listenTo Backbone, "pp:login-with-twitter", @loginWithTwitter
            @listenTo Backbone, "pp:login-with-persona", @loginWithPersona


        checkUser: ->
            if @model.needsToRegister()
                Backbone.history.navigate "/register",
                    trigger: true
                    replace: true
                return

            @checkEmailConfirmed()

        checkEmailConfirmed: ->
            if @model.get("registered")
                if @model.get("settings").email and not @model.get("settings").email_confirmed
                    Backbone.trigger(
                        "pp:notify"
                        "warning"
                        """Your email address is not confirmed. Click the link we sent to #{ @model.get("settings").email } to confirm it.<br>(You can resend it from <a href="/settings">your settings</a> if necessary.)"""
                    )
                else if @model.get("default_upic") and @model.get("age") > 30
                    Backbone.trigger(
                        "pp:notify"
                        "warning"
                        """You don't have a profile picture yet. You can upload one <a href="/settings">upload one from your settings</a>."""
                    )

        backendLogout: ->
            transitional = new Transitional message: 'Logging out...'

            $.post("/api/logout")
            .done =>
                window.location = "/"
            .fail =>
                Backbone.trigger "pp:notify", "error", "Logout failed."
                transitional.remove()

        setRealm: (realm_id) ->
            if realm_id?
                url = "/realm/#{realm_id}/quest/add"
            else
                url = "/quest/add"
            @$(".quest-add-link").attr "href", url

        logout: ->
            # TODO - show "Signing out..." view
            if @model.get("persona_user")
                navigator.id.logout() # will call backendLogout
            else
                @backendLogout()
