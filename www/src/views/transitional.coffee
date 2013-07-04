define [
    "underscore", "jquery"
    "views/proto/common", "text!templates/transitional.html"
], (_, $, Common, html) ->
    class extends Common
        template: _.template(html)
        className: 'transitional'
        selfRender: true
        serialize: ->
            message: @options.message

        initialize: ->
            super
            @$el.appendTo document.body
            @backdrop = $('<div class="transitional-backdrop"></div>')
            @backdrop.appendTo document.body

        remove: ->
            super
            @backdrop.remove()
