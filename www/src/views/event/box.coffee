define ["views/proto/common", "views/event/any", "text!templates/event-box.html"], (Common, Event, html) ->
    class extends Common
        template: _.template(html)
        className: "event-box-view"
        subviews:
            ".subview": ->
                new Event(model: @model)

        serialize: ->
            params = super
            params.showRealm = @options.showRealm
            params
