define ["underscore", "jquery", "views/proto/common", "text!templates/confirm-email.html"], (_, $, Common, html) ->
    Common.extend
        template: _.template(html)
        selfRender: true
        afterInitialize: ->
            $.post("/api/register/confirm_email", @options).done(->
                $(".alert").alert "close"
                ga "send", "event", "confirm-email", "ok"
                mixpanel.track "confirm-email ok"
                Backbone.trigger "pp:notify", "success", "Email confirmed."
                Backbone.history.navigate "/",
                    trigger: true
                    replace: true

            ).fail (response) ->
                ga "send", "event", "confirm-email", "failed"
                mixpanel.track "confirm-email failed"
                Backbone.history.navigate, "/",
                    trigger: true
                    replace: true
