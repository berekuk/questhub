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
                    notify_followers: 1
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

        enableForm: ->
            @$("[name=login]").prop "disabled", false

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

        _registerDone: (data) ->
            if data.status is "conflict"
                ga "send", "event", "register", "conflict"
                mixpanel.track "register conflict"
                @$(".settings-conflict-" + data.reason).show()
                @subview(".progress-subview").off()
                @submitted = false
                @validate()
                return

            if data.status != "ok"
                alert "unknown backend /register status: " + data.status
                return

            ga "send", "event", "register", "ok"
            mixpanel.track "register ok"
            currentUser.fetch
                success: ->
                    mixpanel.alias currentUser.get("_id")
                    mixpanel.people.set
                        $created: new Date()

                    Backbone.history.navigate "/start-tour",
                        trigger: true
                        replace: true
                error: ->
                    Backbone.history.navigate "/welcome",
                        trigger: true


        _registerFail: (response) ->
            ga "send", "event", "register", "fail"
            mixpanel.track "register fail"

            # let's hope that server didn't register the user before it returned a error
            @subview(".progress-subview").off()
            @submitted = false
            @validate()

        doRegister: ->
            return unless @enabled
            ga "send", "event", "register", "submit"
            mixpanel.track "register submit"
            @subview(".progress-subview").on()

            $.post "/api/register",
                login: @getLogin()
                settings: JSON.stringify(
                    notify_likes: 1
                    notify_invites: 1
                    notify_comments: 1
                    notify_followers: 1
                    email: @$("[name=email]").val() # TODO - validate email
                )
            .done (data) =>
                @_registerDone(data)
            .fail (response) =>
                @_registerFail(response)

            @submitted = true
            @validate()

        cancel: ->
            @disable()
            @disableForm()
            @$(".cancel").addClass "disabled"
            ga "send", "event", "register", "cancel"
            mixpanel.track "register cancel"
            @subview(".progress-subview").on()

            $.post("/api/register/cancel")
            .done (model, response) =>
                navigator.id.logout()
                Backbone.history.navigate "/",
                    trigger: true

            .fail =>
                @$(".cancel").removeClass "disabled"
                @enableForm()
                @validate()
                @subview(".progress-subview").off()
