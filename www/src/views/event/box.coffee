define ["views/proto/common", "views/event/any", "text!templates/event-box.html"], (Common, Event, html) ->
    Common.extend
        template: _.template(html)
        className: "event-box-view"
        subviews:
            ".subview": ->
                new Event(model: @model)

        serialize: ->
            params = @model.toJSON()
            params.showRealm = @options.showRealm
            params


