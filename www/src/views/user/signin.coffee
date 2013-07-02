define [
    "underscore", "backbone"
    "views/proto/common"
    "text!templates/signin.html"
], (_, Backbone, Common, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .login-with-persona": "loginWithPersona"
            "click .login-with-twitter": "loginWithTwitter"

        loginWithPersona: ->
            mixpanel.track "signin", how: "persona"
            navigator.id.request()

        loginWithTwitter: ->
            # this may slow things down. oops.
            mixpanel.track "signin", how: "twitter", ->
                window.location = '/auth/twitter'

            # so we're setting a timeout in case mixpanel.track falls off track
            window.setTimeout ->
                window.location = '/auth/twitter'
            , 300
