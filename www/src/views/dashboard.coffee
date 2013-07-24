define [
    "underscore"
    "views/proto/tabbed"
    "views/user/big",
    "views/dashboard/quests", "views/dashboard/activity", "views/dashboard/profile"
    "models/current-user",
    "text!templates/dashboard.html"
], (_, Tabbed, UserBig, DashboardQuests, DashboardActivity, DashboardProfile, currentUser, html) ->
    class extends Tabbed
        template: _.template(html)
        activated: false
        activeMenuItem: -> (if @my() then "my-quests" else "none")

        pageTitle: -> @model.get "login"

        subviews: ->
            subviews = super
            subviews[".user-subview"] = ->
                new UserBig
                    model: @model
                    tab: @tab
            subviews

        tab: 'quests'
        tabSubview: '.dashboard-subview'
        urlRoot: -> "/player/#{ @model.get('login') }"
        tabs:
            quests:
                url: ''
                subview: ->
                    new DashboardQuests
                        model: @model
                        tab: @options.questTab
            activity:
                url: '/activity'
                subview: -> new DashboardActivity model: @model
            profile:
                url: '/profile'
                subview: -> new DashboardProfile model: @model

        initSubviews: ->
            super
            @listenTo @subview(".user-subview"), "switch", (params) ->
                @switchTabByName params.tab

        my: ->
            currentLogin = currentUser.get("login")
            return true if currentLogin and currentLogin is @model.get("login")
            false

        tourGotQuest: ->
            @$(".newbie-tour-expect-quest").hide()
            @$(".newbie-tour-got-quest").show()
            mixpanel.track "first quest on tour"

        onTour: ->
            @my() and currentUser.onTour("profile")

        serialize: ->
            tour = @onTour()
            @listenToOnce Backbone, "pp:quest-add", @tourGotQuest if tour

            tour: tour
