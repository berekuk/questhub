define [
    "underscore"
    "views/proto/paged-collection"
    "views/quest/small"
    "text!templates/quest/collection.html", "jquery-ui"
], (_, PagedCollection, QuestSmall, html) ->
    class extends PagedCollection
        template: _.template(html)
        listSelector: ".quests-list"
        generateItem: (quest) ->
            new QuestSmall(
                model: quest
                user: @options.user
                showStatus: @options.showStatus
                showRealm: @options.showRealm
            )

        saveManualOrder: ->
            if @ordering
                @moreOrdering = true
                return
            questIds = _.map(@$("tr.quest-row td"), (e) ->
                e.getAttribute "data-quest-id"
            )
            deferred = @collection.saveManualOrder(questIds)
            @ordering = true
            @trigger "save-order"
            that = this
            deferred.always ->
                that.ordering = false
                if that.moreOrdering
                    that.moreOrdering = false
                    that.saveManualOrder()
                else
                    that.moreOrdering = false
                    that.trigger "order-saved"


        afterRender: ->
            if @options.sortable
                @$("tbody").sortable(helper: (e, ui) ->
                    ui.children().each ->
                        $(this).width $(this).width()

                    ui
                ).disableSelection()
                that = this
                @$("tbody").on "sortupdate", ->
                    that.saveManualOrder()

            super
