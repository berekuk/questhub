# collection which shows first N items, and then others can be fetched by clicking "show more" button
# your view is going to need:
# 1) template with a clickable '.show-more' element and with '.progress-spin' element
# 2) listSelector, just like in AnyCollection
# 3) generateItem, just like in AnyCollection
define [
    "views/proto/any-collection"
    "views/progress"
], (AnyCollection, Progress) ->
    class extends AnyCollection
        events:
            "click .show-more": "showMore"

        subviews:
            ".progress-spin": -> new Progress()

        insertOne: (el, options) ->
            if options and options.prepend
                @$(@listSelector).prepend el
            else
                @$(".show-more").before el

        activated: true
        pageSize: 100
        noProgress: ->
            @$(".show-more").removeClass "disabled"
            @subview(".progress-spin").off()

        updateShowMore: ->
            @$(".show-more").toggle @collection.gotMore

        initialize: ->
            super
            @subview(".progress-spin").on() # app.js fetches the collection for the first time immediately
            @listenTo @collection, "error fetch-page", @noProgress
            @listenTo @collection, "error", @noProgress
            @listenTo @collection, "fetch-page sync reset", @updateShowMore
            @render()

        showMore: ->
            @$(".show-more").addClass "disabled"
            @subview(".progress-spin").on()
            @collection.fetchMore @pageSize
