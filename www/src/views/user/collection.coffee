define [
    "underscore"
    "views/proto/paged-collection"
    "views/user/small"
    "text!templates/user/collection.html"
], (_, PagedCollection, UserSmall, html) ->
    PagedCollection.extend
        template: _.template(html)
        activeMenuItem: "user-list"
        listSelector: ".users-list"
        realm: ->
            @collection.options.realm

        generateItem: (model) ->
            new UserSmall(
                model: model
                realm: @realm()
            )
