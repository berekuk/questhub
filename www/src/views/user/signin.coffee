define [
    "underscore", "backbone"
    "views/proto/common"
    "text!templates/signin.html"
], (_, Backbone, Common, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .login-with-persona": -> Backbone.trigger "pp:login-with-persona"
            "click .login-with-twitter": -> Backbone.trigger "pp:login-with-twitter"

        serialize: ->
            size: @options.size
