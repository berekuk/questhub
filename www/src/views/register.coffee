# TODO - refactor into views/proto/form
define [
    "underscore", "jquery"
    "views/proto/common"
    "models/current-user"
    "views/progress/big"
    "text!templates/register.html"
], (_, $, Common, currentUser, ProgressBig, html) ->
    class extends Common
        template: _.template(html)
        activeMenuItem: "home"
        events:
            "click .submit": "doRegister"
            "click .cancel": "cancel"
            "keyup [name=login]": "editLogin"
            "keyup [name=email]": "editEmail"

        pageTitle: -> "Register"

        subviews:
            ".progress-subview": -> new ProgressBig()

        render: ->
            super
            @validate()
            @$("[name=login]").focus()

        getLogin: -> @$("[name=login]").val()
        getEmail: -> @$("[name=email]").val()

        disable: ->
            @$(".submit").addClass "disabled"
            @enabled = false

        enable: ->
            @$(".submit").removeClass "disabled"
            @enabled = true
            @submitted = false

        disableForm: -> @$("[name=login]").prop "disabled", true
        enableForm: -> @$("[name=login]").prop "disabled", false

        validate: ->
            login = @getLogin()
            if login.match(/^\w*$/)
                @$(".login-form").removeClass "error"
            else
                @$(".login-form").addClass "error"
                login = undefined
            if @submitted or not login
                @disable()
                return
            if not @getEmail() && not (@model.get('settings') && @model.get('settings').email_confirmed == 'persona')
                @disable()
                return
            @enable()

        editLogin: (e) ->
            @$(".settings-conflict-login").hide()
            @validate()
            @checkEnter(e)

        editEmail: (e) ->
            @$(".settings-conflict-email").hide()
            @validate()
            @checkEnter(e)

        checkEnter: (e) ->
            @doRegister() if e.keyCode is 13

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
            mixpanel.people.set
                $created: new Date()

            currentUser.fetch
                success: =>
                    mixpanel.alias currentUser.get("_id")

                    Backbone.history.navigate "/start-tour",
                        trigger: true
                        replace: true
                error: =>
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

            notify = @$("[name=notify]").is(":checked")
            settings =
                notify_likes: notify
                notify_invites: notify
                notify_comments: notify
                notify_followers: notify
                newsletter: @$("[name=newsletter]").is(":checked")
                email: @getEmail() # TODO - validate email

            $.post "/api/register",
                login: @getLogin()
                settings: JSON.stringify settings
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
