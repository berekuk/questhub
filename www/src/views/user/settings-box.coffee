# Here's the problem with modal views: you can't re-render them.
# Because when they have an internal state (background fade), and rendering twice means that you won't be able to close your modal, or it won't render at all.
# I'm not sure I understand it completely, but... I had problems with that.
#
# Because of that, UserSettingsBox and UserSettings are two different views.
#
# Also, separating modal view logic is a Good Thing in any case. This view can become 'views/proto/modal' in the future.
define ["underscore", "views/proto/common", "views/user/settings", "models/current-user", "text!templates/user-settings-box.html"], (_, Common, UserSettings, currentUser, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click button.submit": "submit"

        subviews:
            ".settings-subview": ->
                new UserSettings(model: @model)

        afterInitialize: ->
            @setElement $("#user-settings") # settings-box is a singleton

        enable: ->
            @$(".icon-spinner").hide()
            @subview(".settings-subview").start()
            @$(".btn-primary").removeClass "disabled"

        disable: ->
            @$(".icon-spinner").show()
            @$(".btn-primary").addClass "disabled"
            @subview(".settings-subview").stop()

        start: ->
            @render()
            @$(".modal").modal "show"
            @disable()
            @model.clear()
            that = this
            @model.fetch
                success: ->
                    that.enable()

                error: ->
                    Backbone.trigger "pp:notify", "error", "Unable to fetch settings"
                    that.$(".modal").modal "hide"


        submit: ->
            ga "send", "event", "settings", "save"
            @disable()
            that = this
            @subview(".settings-subview").save
                success: ->
                    that.$(".modal").modal "hide"
                    # Just to be safe.
                    # Also, if email was changed, we want to trigger the 'sync' event and show the notify box.
                    currentUser.fetch()

                error: ->
                    Backbone.trigger "pp:notify", "error", "Failed to save new settings"
                    that.$(".modal").modal "hide"
