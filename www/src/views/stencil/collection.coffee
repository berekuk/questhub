define [
    "underscore", "backbone"
    "views/proto/any-collection"
    "views/stencil/small"
    "text!templates/stencil/collection.html", "jquery-ui"
], (_, Backbone, Parent, StencilSmall, html) ->
    class extends Parent
        template: _.template(html)
        listSelector: ".stencils-list"

        initialize: ->
            super
            @listenTo Backbone, "pp:stencil-add", (model) =>
                if model.get('realm') == @collection.options.realm
                    @collection.add model, prepend: true

        generateItem: (model) ->
            new StencilSmall model: model
