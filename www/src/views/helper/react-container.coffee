define [
    "underscore", "views/proto/base"
    "react"
], (_, Base, React) ->
    class extends Base
        template: _.template("<div></div>")

        isReactComponent: true

        render: ->
            React.renderComponent @options.component, @$el[0]

        remove: ->
            React.unmountComponentAtNode @$el[0]
            super
