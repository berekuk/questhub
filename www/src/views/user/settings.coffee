define ["underscore", "jquery", "views/proto/common", "settings", "text!templates/user-settings.html"], (_, $, Common, instanceSettings, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .resend-email-confirmation": "resendEmailConfirmation"
            "keyup [name=email]": "typing"

        resendEmailConfirmation: ->
            btn = @$(".resend-email-confirmation")
            return  if btn.hasClass("disabled")
            btn.addClass "disabled"
            $.post("/api/register/resend_email_confirmation", {}).done(->
                btn.text "Confirmation key sent"
            ).fail ->
                btn.text "Confirmation key resending failed"


        serialize: ->
            params = @model.toJSON()
            params.hideEmailStatus = @hideEmailStatus
            params

        start: ->
            @running = true
            @render()
            @$(".email-status").show()
            @$("input").prop "disabled", false
            @hideEmailStatus = false

        stop: ->
            @running = false
            @$(".email-status").hide()
            @$("input").prop "disabled", true

        typing: ->
      
            # We need both.
            # First line hides status immediately...
            @$(".email-status").hide()
      
            # Second line guarantees that it doesn't show up for a moment when we call save() and re-render.
            @hideEmailStatus = true

    
        # i.e., parse the DOM and return the model params
        deserialize: ->
            settings =
                email: @$("[name=email]").val() # TODO - validate email
                notify_comments: @$("[name=notify-comments]").is(":checked")
                notify_likes: @$("[name=notify-likes]").is(":checked")
                notify_invites: @$("[name=notify-invites]").is(":checked")

            settings

        save: (cbOptions) ->
            @model.save @deserialize(), cbOptions


