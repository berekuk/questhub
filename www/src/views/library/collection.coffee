define [
    "underscore", "backbone"
    "views/proto/any-collection"
    "views/library/quest-small"
    "text!templates/library/collection.html", "jquery-ui"
], (_, Backbone, Parent, LibraryQuestSmall, html) ->
    class extends Parent
        template: _.template(html)
        listSelector: ".library-quests-list"

        initialize: ->
            super
            @listenTo Backbone, "pp:library-quest-add", (model) =>
                if model.get('realm') == @collection.options.realm
                    @collection.add model, prepend: true

        generateItem: (model) ->
            new LibraryQuestSmall model: model
