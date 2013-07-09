define [
    "underscore"
    "views/proto/any-collection"
    "views/library/quest-small"
    "text!templates/library/collection.html", "jquery-ui"
], (_, Parent, LibraryQuestSmall, html) ->
    class extends Parent
        template: _.template(html)
        listSelector: ".library-quests-list"

        generateItem: (model) ->
            new LibraryQuestSmall model: model
