define [
    "views/realm/small"
    "views/proto/any-collection"
    "text!templates/realm/collection.html"
], (RealmSmall, AnyCollection, html) ->
    class extends AnyCollection
        template: _.template(html)
        activated: true
        generateItem: (model) ->
            new RealmSmall(model: model)

        listSelector: ".realm-collection-list"

        serialize: ->
            params = super
            params.realmCount = @collection.length
            params
