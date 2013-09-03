define [
    "underscore", "markdown"
], (_, markdown) ->
    class extends Backbone.View
        render: ->
            @$el.html markdown(@options.text || "", @options.realm)

        setText: (text) ->
            @options.text = text
            @render()
