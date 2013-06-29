# left column of the dashboard page
define ["underscore", "views/proto/common", "models/current-user", "views/quest/add", "text!templates/user-big.html"], (_, Common, currentUser, QuestAdd, html) ->
    Common.extend
        template: _.template(html)
        realm: ->
            @options.realm

        events:
            "click .quest-add-dialog": "newQuestDialog"
            "click .settings": "settingsDialog"

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

        features: ["tooltip"]


