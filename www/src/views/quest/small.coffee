define [
    "underscore"
    "views/proto/common"
    "views/quest/like"
    "text!templates/quest/small.html"
], (_, Common, Like, html) ->
    Common.extend
        template: _.template(html)
        tagName: "tr"
        className: "quest-row"
        events:
            mouseenter: (e) ->
                @subview(".likes").showButton()

            mouseleave: (e) ->
                @subview(".likes").hideButton()

        subviews:
            ".likes": ->
                new Like(
                    model: @model
                    hidden: true
                )

        serialize: ->
            params = @model.serialize()
            params.user = @options.user
            params.showStatus = @options.showStatus
            params.showRealm = @options.showRealm
            params

        afterRender: ->
            className = "quest-" + @model.extStatus()
            @$el.addClass className

        features: ["tooltip"]


