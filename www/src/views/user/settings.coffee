define [
    "underscore", "jquery"
    "views/proto/common"
    "settings", "models/user-settings", "models/current-user"
    "text!templates/user/settings.html"
], (_, $, Common, instanceSettings, UserSettingsModel, currentUser, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .resend-email-confirmation": "resendEmailConfirmation"
            "keyup [name=email]": "typing"
            "click button.js-generate-token": "generateApiToken"
            "click button.submit": "submit"

        initialize: ->
            super
            @model = new UserSettingsModel()

            # now settings box will show the preview of (probably) correct settings even before it refetches its actual version
            # (see SettingsBox code for the details)
            settingsData = currentUser.get("settings") or {}
            @model.clear().set settingsData

        resendEmailConfirmation: ->
            btn = @$(".resend-email-confirmation")
            return if btn.hasClass("disabled")
            btn.addClass "disabled"

            mixpanel.track "confirm-email resend"
            $.post("/api/register/resend_email_confirmation", {}).done(->
                btn.text "Confirmation key sent"
            ).fail ->
                btn.text "Confirmation key resending failed"

        generateApiToken: (e) ->
            mixpanel.track "generate token", regenerate: $(e.target).hasClass('regenerate-token')
            @listenToOnce @model, "change:api_token", => @render()
            @model.generateApiToken()

        serialize: ->
            params = super
            console.trace()
            params.hideEmailStatus = @hideEmailStatus
            params

        enable: ->
            @$(".icon-spinner").hide()
            @$(".btn-primary").removeClass "disabled"

        disable: ->
            @$(".icon-spinner").show()
            @$(".btn-primary").addClass "disabled"
            @$(".email-status").hide()
            @$("input").prop "disabled", true

        render: ->
            super
            unless @rerender
                @rerender = true
                @disable()
                @$(".email-status").show()
                @$("input").prop "disabled", false
                @hideEmailStatus = false
                @model.clear()
                @model.fetch
                    success: =>
                        @enable()
                    error: =>
                        Backbone.trigger "pp:notify", "error", "Unable to fetch settings"
                        # TODO - go to /?

        typing: ->
            # We need both.
            # First line hides status immediately...
            @$(".email-status").hide()
            # Second line guarantees that it doesn't show up for a moment when we call save() and re-render.
            @hideEmailStatus = true

        # parse the DOM and return the model params
        deserialize: ->
            settings =
                email: @$("[name=email]").val() # TODO - validate email
                notify_comments: @$("[name=notify-comments]").is(":checked")
                notify_likes: @$("[name=notify-likes]").is(":checked")
                notify_invites: @$("[name=notify-invites]").is(":checked")
                notify_followers: @$("[name=notify-followers]").is(":checked")
                newsletter: @$("[name=newsletter]").is(":checked")

            settings

        submit: ->
            ga "send", "event", "settings", "save"
            @disable()
            @model.save @deserialize(),
                success: =>
                    # Just to be safe.
                    # Also, if email was changed, we want to trigger the 'sync' event and show the notify box.
                    currentUser.fetch()
                    Backbone.history.navigate "/", trigger: true
                error: =>
                    Backbone.trigger "pp:notify", "error", "Failed to save new settings"
