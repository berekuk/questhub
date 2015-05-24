define [
    "underscore"
    "views/proto/common"
    "views/quest/like"
    "raw!templates/quest/small.html"
], (_, Common, Like, html) ->
    class extends Common
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
            params = super
            params.user = @options.user
            params.showStatus = @options.showStatus
            params.showRealm = @options.showRealm
            params

        render: ->
            super
            className = "quest-" + @model.extStatus()
            @$el.addClass className

        features: ["tooltip"]
