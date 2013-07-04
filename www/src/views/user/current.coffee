define [
    "backbone", "underscore"
    "views/proto/common"
    "views/user/notifications-box", "views/user/settings-box"
    "models/current-user", "models/user-settings"
    "views/transitional"
    "text!templates/current-user.html"
], (Backbone, _, Common, NotificationsBox, UserSettingsBox, currentUser, UserSettingsModel, Transitional, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .logout": "logout"
            "click .settings": "settingsDialog"
            "click .login-with-persona": "loginWithPersona"
            "click .login-with-twitter": "loginWithTwitter"
            "click .notifications": "notificationsDialog"

        loginWithPersona: ->
            mixpanel.track "signin", how: "persona"

            # a precaution against "navigator.id.watch must be called before navigator.id.request" race condition
            # (I don't know how exactly this race happens, but I've seen it in the wild)
            @setPersonaWatch if not @personaWatch

            navigator.id.request()

        loginWithTwitter: ->
            # this may slow things down. oops.
            mixpanel.track "signin", how: "twitter", ->
                window.location = '/auth/twitter'

            # so we're setting a timeout in case mixpanel.track falls off track
            window.setTimeout ->
                window.location = '/auth/twitter'
            , 300

        getSettingsBox: ->
            @_settingsBox = new UserSettingsBox(model: new UserSettingsModel())  unless @_settingsBox
            @_settingsBox

        settingsDialog: ->
            @getSettingsBox().start()

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
            @listenTo @model, "change", ->
                settingsModel = @model.get("settings") or {}

                # now settings box will show the preview of (probably) correct settings even before it refetches its actual version
                # (see SettingsBox code for the details)
                @getSettingsBox().model.clear().set settingsModel

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
            if @model.get("registered") and @model.get("settings").email and not @model.get("settings").email_confirmed
                Backbone.trigger(
                    "pp:notify"
                    "warning"
                    "Your email address is not confirmed. Click the link we sent to #{ @model.get("settings").email } to confirm it. (You can resend it from your settings if necessary.)"
                )

        backendLogout: ->
            transitional = new Transitional message: 'Logging out...'

            $.post("/api/logout")
            .done =>
                window.location = "/"
            .fail =>
                Backbone.trigger "pp:notify", "error", "Logout failed."
                transitional.remove()


        logout: ->
            # TODO - show "Signing out..." view
            if @model.get("persona_user")
                navigator.id.logout() # will call backendLogout
            else
                @backendLogout()
