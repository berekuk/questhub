define [
    "underscore"
    "views/proto/common"
    "models/current-user"
    "views/quest/add"
    "text!templates/user/big.html"
], (_, Common, currentUser, QuestAdd, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .quest-add-dialog": "newQuestDialog"
            "click .settings": "settingsDialog"
            "click .user-big-tabs div._icon": "switch"
            "click button.user-big-follow": "follow"
            "click button.user-big-unfollow": "unfollow"

        initialize: ->
            @tab = @options.tab || 'quests'
            super
            @listenTo currentUser, 'change', @render # re-render if "follow" is clicked

        settingsDialog: ->
            Backbone.trigger "pp:settings-dialog"

        serialize: ->
            params = super
            currentLogin = currentUser.get("login")
            params.registered = currentUser.get("registered")
            params.my = (currentLogin and currentLogin is @model.get("login"))
            params.following = @model.get("login") in (currentUser.get('fu') || [])
            params.tab = @tab
            params

        newQuestDialog: ->
            questAdd = new QuestAdd()
            @$el.append questAdd.$el # FIXME - DOM memory leak
            ga "send", "event", "quest", "new-dialog"

        follow: -> currentUser.followUser @model.get("login")
        unfollow: -> currentUser.unfollowUser @model.get("login")

        switch: (e) ->
            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            @trigger "switch", tab: @tab
            t.closest("ul").find("._active").removeClass "_active"
            t.addClass "_active"

        features: ["tooltip"]
