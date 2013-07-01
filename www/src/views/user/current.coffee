define ["backbone", "underscore", "views/proto/common", "views/user/notifications-box", "views/user/settings-box", "models/current-user", "models/user-settings", "text!templates/current-user.html"], (Backbone, _, Common, NotificationsBox, UserSettingsBox, currentUser, UserSettingsModel, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .logout": "logout"
            "click .settings": "settingsDialog"
            "click .login-with-persona": "loginWithPersona"
            "click .notifications": "notificationsDialog"

        loginWithPersona: ->
            navigator.id.request()

        getSettingsBox: ->
            @_settingsBox = new UserSettingsBox(model: new UserSettingsModel())  unless @_settingsBox
            @_settingsBox

        settingsDialog: ->
            @getSettingsBox().start()

        notificationsDialog: ->
            @_notificationsBox = new NotificationsBox(model: @model)  unless @_notificationsBox
            @_notificationsBox.start()

        setPersonaWatch: ->
            persona = @model.get("persona")
            user = null
            user = @model.get("settings").email  if @model.get("settings") and @model.get("settings").email and @model.get("settings").email_confirmed and @model.get("settings").email_confirmed is "persona"
            view = this
            navigator.id.watch
                loggedInUser: user
                onlogin: (assertion) ->

                    # A user has logged in! Here you need to:
                    # 1. Send the assertion to your backend for verification and to create a session.
                    # 2. Update your UI.
                    $.ajax
                        type: "POST"
                        url: "/auth/persona"
                        data:
                            assertion: assertion

                        success: (res, status, xhr) ->
                            view.model.fetch()

                        error: (xhr, status, err) ->
                            Backbone.trigger "pp:notify", "error", "/auth/persona failed."


                onlogout: ->

                    # sometimes persona decides that it should log out the twitter user, so we're trying to prevent it here
                    # it happens often in confusion of localhost:3000 and localhost:3001 in development, since persona only works for :3000
                    view.backendLogout()  if view.model.get("settings") and view.model.get("settings").email_confirmed is "persona"


        afterInitialize: ->
            @model.once "sync", @setPersonaWatch, this
            @listenTo @model, "sync", @checkUser
            @listenTo @model, "change", @render
            @listenTo @model, "change", ->
                settingsModel = @model.get("settings") or {}

                # now settings box will show the preview of (probably) correct settings even before it refetches its actual version
                # (see SettingsBox code for the details)
                @getSettingsBox().model.clear().set settingsModel


        checkUser: ->
            if @model.needsToRegister()
                ga "send", "event", "register", "new-dialog"
                Backbone.history.navigate "/register",
                    trigger: true
                    replace: true

                return
            @checkEmailConfirmed()

        checkEmailConfirmed: ->
            Backbone.trigger "pp:notify", "warning", "Your email address is not confirmed. Click the link we sent to " + @model.get("settings").email + " to confirm it. (You can resend it from your settings if necessary.)"  if @model.get("registered") and @model.get("settings").email and not @model.get("settings").email_confirmed

        backendLogout: ->
            $.post("/api/logout").always ->
                window.location = "/"


        logout: ->

            # TODO - fade to black until response
            if @model.get("settings") and @model.get("settings").email_confirmed is "persona"
                navigator.id.logout()
            else
                @backendLogout()
