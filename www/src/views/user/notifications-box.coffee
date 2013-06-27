define ["underscore", "views/proto/common", "views/user/notifications", "text!templates/notifications-box.html"], (_, Common, Notifications, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .btn-primary": "next"

        subviews:
            ".subview": ->
                new Notifications(model: @model)

        afterInitialize: ->
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
            that = this
            @model.dismissNotification(@current()._id).always ->
                that.model.fetch().done(->
                    unless that.current()
                        that.$(".modal").modal "hide"
                        return
                    that.subview(".subview").render()
                ).fail ->
                    that.$(".modal").modal "hide"




