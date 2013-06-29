define ["underscore", "views/proto/common", "models/current-user", "views/quest/collection", "views/progress", "views/progress/big", "text!templates/dashboard-quest-collection.html"], (_, Common, currentUser, QuestCollection, Progress, ProgressBig, html) ->
    Common.extend
        template: _.template(html)
        subviews:
            ".quests": ->
                new QuestCollection(
                    collection: @collection
                    showRealm: true
                    user: @options.user # FIXME - get this from collection instead?
                    sortable: @options.sortable
                )

            ".progress-subview": ->
                new ProgressBig()

            ".order-progress-subview": ->
                new Progress()

        events:
            "click .show-tags": (e) ->
                mode = ((if e.currentTarget.checked then "normal" else "dense"))
                currentUser.setSetting "quest-collection-view-mode", mode
                @setViewMode mode

        setViewMode: (mode) ->
            if mode is "normal"
                @$(".quests-list").removeClass "quests-list-tagless"
            else
                @$(".quests-list").addClass "quests-list-tagless"

        afterInitialize: ->
            view = this
            @listenTo @collection, "reset add remove", ->
                @subview(".progress-subview").off()
                @fetched = true
                @showOrHide()

            @subview(".progress-subview").on()

        showOrHide: ->
            innerEl = @$el.find(".quest-collection-inner")
            if @fetched
                innerEl.show()
                unless @collection.length
                    @$(".quest-filter").hide()
                else
                    @$(".quest-filter").show()
            else
                innerEl.hide()
            length = @collection.length
            length += "+"  if @collection.gotMore
            @$(".quest-collection-header-count").text length
            @setViewMode @getViewMode()

        getViewMode: ->
            viewMode = currentUser.getSetting("quest-collection-view-mode")
            viewMode = viewMode or "normal"
            viewMode

        serialize: ->
            caption: @options.caption
            length: @collection.length
            collection: @collection
            viewMode: @getViewMode()

        afterRender: ->
            sv = @subview(".quests")
            @listenTo sv, "save-order", ->
                @subview(".order-progress-subview").on()

            @listenTo sv, "order-saved", ->
                @subview(".order-progress-subview").off()

            @listenTo sv, "render", @showOrHide


