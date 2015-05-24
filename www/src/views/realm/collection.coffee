define [
    "underscore"
    "views/realm/small"
    "views/proto/any-collection"
    "raw!templates/realm/collection.html"
], (_, RealmSmall, AnyCollection, html) ->
    class extends AnyCollection
        template: _.template(html)
        generateItem: (model) ->
            new RealmSmall(model: model)

        listSelector: ".realm-collection-list"

        serialize: ->
            params = super
            params.realmCount = @collection.length
            params
