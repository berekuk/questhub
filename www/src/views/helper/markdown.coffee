define [
    "underscore", "markdown"
], (_, markdown) ->
    class extends Backbone.View
        render: ->
            @$el.html """<div class="md #{"md-editable" if @options.editable else ""}">#{markdown(@options.text || "", @options.realm)}</div>"""

        setText: (text) ->
            @options.text = text
            @render()
