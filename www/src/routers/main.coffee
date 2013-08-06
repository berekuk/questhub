define [
    "backbone"
    "routers/proto/common"
    "models/current-user"
    "views/welcome"
    "views/news-feed"
    "views/register"
    "views/confirm-email", "views/user/unsubscribe"
], (Backbone, Common, currentUser, Welcome, NewsFeed, Register, ConfirmEmail, Unsubscribe) ->

    class extends Common
        routes:
            "": "feed"
            "welcome": "welcome"
            "register": "register"
            "register/confirm/:login/:secret": "confirmEmail"
            "auth/twitter": "twitterLogin"
            "player/:login/unsubscribe/:field/:status": "unsubscribeResult"
            "start-tour": "startTour"

        welcome: ->
            # model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            @appView.setPageView new Welcome(model: currentUser)

        feed: ->
            return unless @_checkLogin()
            view = new NewsFeed(model: currentUser)
            view.render()
            @appView.setPageView view

        register: ->
            unless currentUser.needsToRegister()
                @navigate "/",
                    trigger: true
                    replace: true
                return

            ga "send", "event", "register", "new-dialog"
            mixpanel.track "register form"

            view = new Register(model: currentUser)
            @appView.setPageView view # not rendered yet
            view.render()

        startTour: ->
            unless @_checkLogin()
                Backbone.trigger "pp:notify", "error", "You need to be signed in to take a tour, sorry."
                return
            currentUser.startTour()
            Backbone.history.navigate "/realms",
                trigger: true
                replace: true


        confirmEmail: (login, secret) ->
            view = new ConfirmEmail(
                login: login
                secret: secret
            )
            @appView.setPageView view

        unsubscribeResult: (login, field, status) ->
            unless status is "ok"
                mixpanel.track "unsubscribe fail"
            else
                mixpanel.track "unsubscribe",
                    login: login
                    field: field
                    via: "email"

            @navigate "/", # so that nobody links to unsubscribe page - this would be confusing
                replace: true

            view = new Unsubscribe(
                login: login
                field: field
                status: status
            )
            @appView.setPageView view

        twitterLogin: ->
            # unused? remove this route?
            # views/user/signin sets window.location directly now...
            window.location = "/auth/twitter"
