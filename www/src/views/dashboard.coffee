define [
    "underscore"
    "views/proto/common"
    "views/user/big",
    "views/dashboard/quests", "views/dashboard/activity", "views/dashboard/profile"
    "models/current-user",
    "text!templates/dashboard.html"
], (_, Common, UserBig, DashboardQuests, DashboardActivity, DashboardProfile, currentUser, html) ->
    class extends Common
        template: _.template(html)
        activated: false
        activeMenuItem: -> (if @my() then "my-quests" else "none")

        subviews:
            ".user-subview": ->
                new UserBig
                    model: @model
                    tab: @tab

            ".dashboard-subview": ->
                if @tab == 'quests'
                    new DashboardQuests
                        model: @model
                        tab: @options.questTab
                else if @tab == 'activity'
                    new DashboardActivity model: @model
                else if @tab == 'profile'
                    new DashboardProfile model: @model
                else
                    alert "unknown tab #{@tab}"

        initialize: ->
            @tab = @options.tab || 'quests'
            super

        initSubviews: ->
            super
            @listenTo @subview(".user-subview"), "switch", (params) ->
                tab = params.tab
                @switchTabByName tab
                tab2url =
                    quests: ''
                    activity: '/activity'
                    profile: '/profile'
                Backbone.history.navigate "/player/#{ @model.get("login") }#{ tab2url[tab] }"
                Backbone.trigger "pp:quiet-url-update"

        switchTabByName: (tab) ->
            @tab = tab
            @rebuildSubview(".dashboard-subview").render()

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
