# TODO - refactor into views/proto/form
define ["underscore", "jquery", "views/proto/common", "models/user-settings", "models/current-user", "views/user/settings", "views/progress/big", "text!templates/register.html"], (_, $, Common, UserSettingsModel, currentUser, UserSettings, ProgressBig, html) ->
    Common.extend
        template: _.template(html)
        activeMenuItem: "home"
        events:
            "click .submit": "doRegister"
            "click .cancel": "cancel"
            "keydown [name=login]": "checkEnter"
            "keyup [name=login]": "editLogin"
            "keyup [name=email]": "editEmail"

        subviews:
            ".settings-subview": ->
                model = new UserSettingsModel(
                    notify_likes: 1
                    notify_invites: 1
                    notify_comments: 1
                )
                if @model.get("settings")
                    model.set "email", @model.get("settings")["email"]
                    model.set "email_confirmed", @model.get("settings")["email_confirmed"]
                new UserSettings(model: model)

            ".progress-subview": ->
                new ProgressBig()

        afterInitialize: ->
            _.bindAll this

        afterRender: ->
            @validate()
            @$("[name=login]").focus()

        checkEnter: (e) ->
            @doRegister()  if e.keyCode is 13

        getLogin: ->
            @$("[name=login]").val()

        disable: ->
            @$(".submit").addClass "disabled"
            @enabled = false

        enable: ->
            @$(".submit").removeClass "disabled"
            @enabled = true
            @submitted = false

        disableForm: ->
            @$("[name=login]").prop "disabled", true
            @subview(".settings-subview").stop()

        enableForm: ->
            @$("[name=login]").prop "disabled", false
            @subview(".settings-subview").start()

        validate: ->
            login = @getLogin()
            if login.match(/^\w*$/)
                @$(".login").removeClass "error"
            else
                @$(".login").addClass "error"
                login = undefined
            if @submitted or not login
                @disable()
            else
                @enable()

        editLogin: ->
            @$(".settings-conflict-login").hide()
            @validate()

        editEmail: ->
            @$(".settings-conflict-email").hide()

        doRegister: ->
            return  unless @enabled
            that = this
            ga "send", "event", "register", "submit"
            mixpanel.track "register submit"
            @subview(".progress-subview").on()

            # TODO - what should we do if login is empty?
            $.post("/api/register",
                login: @getLogin()
                settings: JSON.stringify(@subview(".settings-subview").deserialize())
            ).done((data) ->
                if data.status is "ok"
                    ga "send", "event", "register", "ok"
                    mixpanel.track "register ok"
                    currentUser.fetch
                        success: ->
                            mixpanel.alias currentUser.get("_id")
                            Backbone.history.navigate "/start-tour",
                                trigger: true
                                replace: true

                        error: ->
                            Backbone.history.navigate "/welcome",
                                trigger: true


                else if data.status is "conflict"
                    ga "send", "event", "register", "conflict"
                    mixpanel.track "register conflict"
                    that.$(".settings-conflict-" + data.reason).show()
                    that.subview(".progress-subview").off()
                    that.submitted = false
                    that.validate()
                else
                    alert "unknown backend /register status: " + data.status
            ).fail (response) ->
                ga "send", "event", "register", "fail"
                mixpanel.track "register fail"

                # let's hope that server didn't register the user before it returned a error
                that.subview(".progress-subview").off()
                that.submitted = false
                that.validate()

            @submitted = true
            @validate()

        cancel: ->
            @disable()
            @disableForm()
            @$(".cancel").addClass "disabled"
            that = this
            ga "send", "event", "register", "cancel"
            mixpanel.track "register cancel"
            @subview(".progress-subview").on()
            $.post("/api/register/cancel").done((model, response) ->
                Backbone.history.navigate "/",
                    trigger: true

            ).fail ->
                that.$(".cancel").removeClass "disabled"
                that.enableForm()
                that.validate()
                that.subview(".progress-subview").off()



