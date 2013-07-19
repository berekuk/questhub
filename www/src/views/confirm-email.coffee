define [
    "underscore", "jquery"
    "views/proto/common"
    "views/transitional"
    "text!templates/confirm-email.html"
], (_, $, Common, Transitional, html) ->
    class extends Common
        template: _.template(html)
        selfRender: true

        initialize: ->
            super

            transitional = new Transitional message: 'Confirming email...'

            $.post("/api/register/confirm_email", @options)
            .done =>
                $(".alert").alert "close"

                mixpanel.track "confirm-email ok"
                Backbone.trigger "pp:notify", "success", "Email confirmed."
                transitional.remove()

                Backbone.history.navigate "/",
                    trigger: true
                    replace: true

            .fail (response) =>
                mixpanel.track "confirm-email failed"
                transitional.remove()

                Backbone.history.navigate "/",
                    trigger: true
                    replace: true
