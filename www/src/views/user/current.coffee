define [], () ->
    class extends Common
        template: _.template(html)
        events:
            "click .logout": -> Backbone.trigger "pp:logout"
            "click .login-with-persona": -> Backbone.trigger "pp:login-with-persona"
            "click .login-with-twitter": -> Backbone.trigger "pp:login-with-twitter"
            "click .notifications": "notificationsDialog"

        notificationsDialog: ->
            @_notificationsBox = new NotificationsBox(model: @model) unless @_notificationsBox
            @_notificationsBox.start()
