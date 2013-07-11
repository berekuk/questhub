define [
    "backbone"
    "views/proto/common"
    "views/user/signin", "models/current-user"
    "text!templates/user/unsubscribe.html"
], (Backbone, Common, Signin, currentUser, html) ->
    Common.extend
        template: _.template(html)
        selfRender: true
        events:
            "click .settings": ->
                Backbone.trigger "pp:settings-dialog"

        subviews:
            ".signin-subview": ->
                new Signin()

        serialize: ->
            params = @options
            params.current_user = currentUser.toJSON()
            params


