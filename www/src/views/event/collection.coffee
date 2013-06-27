define [
  "jquery", "underscore",
  "views/proto/paged-collection",
  "views/event/box",
  "text!templates/event-collection.html"
], ($, _, PagedCollection, EventBox, html) ->
    class extends PagedCollection
        template: _.template html
        listSelector: ".event-collection"
        pageSize: 50
        afterInitialize: ->
            super
            @listenTo Backbone, "pp:quest-add", (model) -> @collection.fetch()

        generateItem: (model) ->
            new EventBox
                model: model
                showRealm: @options.showRealm
