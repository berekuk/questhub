define [
    "backbone"
    "routers/proto/common"
    "models/current-user"
    "views/quest/page", "models/quest"
    "views/welcome"
    "views/news-feed"
    "views/about", "views/register"
    "views/confirm-email", "views/user/unsubscribe"
], (Backbone, Common, currentUser, QuestPage, QuestModel, Welcome, NewsFeed, About, Register, ConfirmEmail, Unsubscribe) ->

    class extends Common
        routes:
            "": "feed"
            "welcome": "welcome"
            "register": "register"
            "register/confirm/:login/:secret": "confirmEmail"
            "auth/twitter": "twitterLogin"
            "player/:login/unsubscribe/:field/:status": "unsubscribeResult"
            "start-tour": "startTour"
            "quest/:id": "questPage"
            "about": "about"
            "realm/:realm/quest/:id": "realmQuestPage"

        questPage: (id) ->
            model = new QuestModel(_id: id)
            view = new QuestPage(model: model)
            model.fetch success: =>
                Backbone.history.navigate "/realm/" + model.get("realm") + "/quest/" + model.id,
                    trigger: true
                    replace: true

                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmQuestPage: (realm, id) ->
            @questPage id

        welcome: ->
            # model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            @appView.setPageView new Welcome(model: currentUser)

        feed: ->
            unless currentUser.get("registered")
                @navigate "/welcome",
                    trigger: true
                    replace: true

                return
            view = new NewsFeed(model: currentUser)
            view.render()
            @appView.setPageView view

        register: ->
            unless currentUser.needsToRegister()
                @navigate "/",
                    trigger: true
                    replace: true

                return
            mixpanel.track "register form"
            view = new Register(model: currentUser)
            @appView.setPageView view # not rendered yet
            view.render()

        startTour: ->
            unless currentUser.get("registered")
                Backbone.trigger "pp:notify", "error", "You need to be signed in to take a tour, sorry."
                @navigate "/welcome",
                    trigger: true
                    replace: true

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

        about: ->
            @appView.setPageView new About()
