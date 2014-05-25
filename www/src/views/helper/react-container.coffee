define [
    "underscore", "backbone"
    "react"
], (_, Backbone, React) ->
    class extends Backbone.View
        template: _.template("<div></div>")

        isReactComponent: true

        render: ->
            React.renderComponent @options.component, @$el[0]

        remove: ->
            React.unmountComponentAtNode @$el[0]
            super
