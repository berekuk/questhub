define ["backbone", "models/current-user", "models/shared-models", "views/dashboard", "views/quest/page", "models/quest", "models/user-collection", "views/user/collection", "models/another-user", "views/explore", "views/welcome", "models/event-collection", "views/news-feed", "views/realm/page", "views/about", "views/register", "views/realm/detail-collection", "models/realm", "views/confirm-email", "views/user/unsubscribe"], (Backbone, currentUser, sharedModels, Dashboard, QuestPage, QuestModel, UserCollectionModel, UserCollection, AnotherUserModel, Explore, Welcome, EventCollectionModel, NewsFeed, RealmPage, About, Register, RealmDetailCollection, RealmModel, ConfirmEmail, Unsubscribe) ->
    router = undefined
    redirect = (tmpl) ->
        (a1, a2, a3) ->
            newRoute = tmpl
            newRoute = newRoute.replace(":1", a1)
            newRoute = newRoute.replace(":2", a2)
            newRoute = newRoute.replace(":3", a3)
            router.navigate "/" + newRoute,
                trigger: true
                replace: true


    Backbone.Router.extend
        routes:
            "": "feed"
            "welcome": "welcome"
            "register": "register"
            "register/confirm/:login/:secret": "confirmEmail"
            "auth/twitter": "twitterLogin"
            "player/:login/unsubscribe/:field/:status": "unsubscribeResult"
            "start-tour": "startTour"
            "quest/:id": "questPage"
            "realm/:realm": "realmPage"
            "player/:login": "dashboard"
            "player/:login/quest/:tab": "dashboard"
            "me": "myDashboard"
            "about": "about"
            "realms": "realms"
            "realm/:realm/players": "userList"
            "realm/:realm/explore(/:tab)": "explore"
            "realm/:realm/explore/:tab/tag/:tag": "explore"
            "realm/:realm/quest/:id": "realmQuestPage"

            # legacy
            "feed": redirect("")
            "perl": redirect("realm/perl")
            "perl/": redirect("realm/perl")
            "players": redirect("")
            "explore": redirect("realm/chaos/explore")
            "explore/:tab": redirect("realm/chaos/explore/:1")
            "explore/:tab/tag/:tag": redirect("realm/chaos/explore/:1/tag/:2")
            ":realm/player/:login": redirect("player/:2")
            ":realm/explore": redirect("realm/:1/explore")
            ":realm/explore/:tab": redirect("realm/:1/explore/:2")
            ":realm/explore/:tab/tag/:tag": redirect("realm/:1/explore/:2/tag/:3")
            ":realm/players": redirect("realm/:1/players")
            ":realm/feed": redirect("realm/:1")
            ":realm/quest/:id": redirect("quest/:2")

        appView: undefined # required

        # Google Analytics
        initialize: (appView) ->
            @appView = appView
            @bind "route", @_trackPageview
            router = this

        _trackPageview: ->
            url = Backbone.history.getFragment()
            url = "/" + url
            ga "send", "pageview",
                page: url

            mixpanel.track_pageview url

        questPage: (id) ->
            model = new QuestModel(_id: id)
            view = new QuestPage(model: model)
            router = this
            model.fetch success: ->
                router.navigate "/realm/" + model.get("realm") + "/quest/" + model.id,
                    trigger: true
                    replace: true

                view.activate()
                router.appView.updateRealm()

            @appView.setPageView view

        realmQuestPage: (realm, id) ->
            @questPage id

        welcome: ->
            # model is usually empty, but sometimes it's not - logged-in users can see the welcome page too
            @appView.setPageView new Welcome(model: currentUser)

        dashboard: (login, tab) ->
            currentLogin = currentUser.get("login")
            model = undefined
            my = undefined
            if currentLogin and currentLogin is login
                model = currentUser
                my = true
            else
                model = new AnotherUserModel(login: login)
            view = new Dashboard(model: model)
            view.tab = tab if tab?
            if my
                view.activate() # activate immediately, user is already fetched
            else
                model.fetch()
                    .success -> view.activate()

            @appView.setPageView view

        myDashboard: ->
            if currentUser.get("registered")
                @navigate "/player/" + currentUser.get("login"),
                    trigger: true
                    replace: true
            else
                @navigate "/welcome",
                    trigger: true
                    replace: true

        explore: (realm, tab, tag) ->
            view = new Explore(realm: realm)
            view.tab = tab if tab?
            view.tag = tag if tag?
            view.activate()
            @appView.setPageView view

        userList: (realm) ->
            collection = new UserCollectionModel([],
                realm: realm
                sort: "leaderboard"
                limit: 100
            )
            view = new UserCollection(collection: collection)
            collection.fetch()
            @appView.setPageView view

        realmPage: (realm) ->
            model = new RealmModel(id: realm)
            view = new RealmPage(model: model)
            model.fetch()
                .success -> view.activate()

            @appView.setPageView view

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
            Backbone.trigger "pp:navigate", "/realms",
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
            window.location = "/auth/twitter"

        about: ->
            @appView.setPageView new About()

        realms: ->
            view = new RealmDetailCollection(collection: sharedModels.realms)
            view.collection.fetch()
            @appView.setPageView view

        queryParams: (name) ->
            name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
            regexS = "[\\?&]" + name + "=([^&#]*)"
            regex = new RegExp(regexS)
            results = regex.exec(window.location.search)
            unless results?
                ""
            else
                decodeURIComponent results[1].replace(/\+/g, " ")
