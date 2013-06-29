define ["underscore", "views/proto/common", "text!templates/signin.html"], (_, Common, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .login-with-persona": "loginWithPersona"

        loginWithPersona: ->
            navigator.id.request()


