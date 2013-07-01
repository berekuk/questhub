define [
    "backbone", "underscore"
    "routers/proto/common"
    "models/current-user", "models/another-user"
    "views/dashboard"
], (Backbone, _, Common, currentUser, AnotherUserModel, Dashboard) ->
    class extends Common
        routes:
            "me": "me"
            "player/:login": "quests"
            "player/:login/quest/:tab": "quests"
            "player/:login/activity": "activity"
            "player/:login/profile": "profile"

        me: ->
            if currentUser.get("registered")
                @navigate "/player/" + currentUser.get("login"),
                    trigger: true
                    replace: true
            else
                @navigate "/welcome",
                    trigger: true
                    replace: true


        _dashboard: (login, options) ->
            currentLogin = currentUser.get("login")
            model = undefined
            my = undefined
            if currentLogin and currentLogin is login
                model = currentUser
                my = true
            else
                model = new AnotherUserModel(login: login)

            view = new Dashboard _.extend(
                { model: model },
                options
            )
            if my
                view.activate() # activate immediately, user is already fetched
            else
                model.fetch()
                    .success -> view.activate()

            @appView.setPageView view

        quests: (login, tab) -> @_dashboard login, questTab: tab
        activity: (login) -> @_dashboard login, tab: 'activity'
        profile: (login) -> @_dashboard login, tab: 'profile'
