define [
  "jquery", "underscore",
  "backbone"
  "views/proto/paged-collection",
  "views/event/any",
  "raw!templates/event-collection.html"
], ($, _, Backbone, PagedCollection, Event, html) ->
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
