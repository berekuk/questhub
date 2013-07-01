# left column of the dashboard page
define ["underscore", "views/proto/common", "models/current-user", "views/quest/add", "text!templates/user-big.html"], (_, Common, currentUser, QuestAdd, html) ->
    Common.extend
        template: _.template(html)
        realm: ->
            @options.realm
        tab: 'quests'

        events:
            "click .quest-add-dialog": "newQuestDialog"
            "click .settings": "settingsDialog"
            "click .user-big-tabs div._icon": "switch"

        settingsDialog: ->
            Backbone.trigger "pp:settings-dialog"

        serialize: ->
            params = @model.toJSON()
            currentLogin = currentUser.get("login")
            params.my = (currentLogin and currentLogin is @model.get("login"))
            params.realm = @realm()
            params

        newQuestDialog: ->
            questAdd = new QuestAdd()
            @$el.append questAdd.$el # FIXME - DOM memory leak
            ga "send", "event", "quest", "new-dialog"

        switch: (e) ->
            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            @trigger "switch", tab: @tab
            t.closest("ul").find("._active").removeClass "_active"
            t.addClass "_active"

        afterRender: ->
            @$(".user-big-tabs [data-tab=" + @tab + "]").addClass "_active"

        features: ["tooltip"]
