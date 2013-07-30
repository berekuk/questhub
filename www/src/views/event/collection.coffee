define [
  "jquery", "underscore",
  "views/proto/paged-collection",
  "views/event/any",
  "text!templates/event-collection.html"
], ($, _, PagedCollection, Event, html) ->
    class extends PagedCollection
        template: _.template html
        listSelector: ".event-collection"
        pageSize: 50
        initialize: ->
            super
            @listenTo Backbone, "pp:quest-add", (model) -> @collection.fetch()

        generateItem: (model) ->
            new Event
                model: model
                showRealm: @options.showRealm
