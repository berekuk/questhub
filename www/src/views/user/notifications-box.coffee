define [
    "underscore"
    "views/proto/common"
    "views/user/notifications"
    "text!templates/notifications-box.html"
], (_, Common, Notifications, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .btn-primary": "next"

        subviews:
            ".subview": ->
                new Notifications(model: @model)

        initialize: ->
            super
            @setElement $("#notifications") # settings-box is a singleton

        start: ->
            return  unless @current()
            @render()
            @$(".modal").modal "show"

        current: ->
            _.first @model.get("notifications")

        serialize: ->
            @current()

        next: ->
            @model.dismissNotification(@current()._id).always =>
                @model.fetch().done(=>
                    unless @current()
                        @$(".modal").modal "hide"
                        return
                    @subview(".subview").render()
                ).fail ->
                    @$(".modal").modal "hide"
