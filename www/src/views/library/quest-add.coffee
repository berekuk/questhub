define [
    "underscore", "jquery"
    "views/proto/common"
    "models/library/quest"
    "text!templates/library/quest-add.html"
], (_, $, Common, Model, html) ->
    class extends Common
        template: _.template html
        selfRender: true

        events:
            "click ._go": "submit"

        initialize: ->
            super
            $("#modal-storage").append @$el
            @$(".modal").modal().on "shown", =>
                @$("[name=name]").focus()
            @$(".modal").modal().on "hidden", (e) =>
                return unless $(e.target).hasClass("modal")
                @remove()

        submit: ->
            params =
                name: @$("[name=name]").val()
                realm: @options.realm

            mixpanel.track "add library quest"
            model = new Model()
            model.save params,
                success: =>
                    Backbone.trigger "pp:library-quest-add", model
                    @$(".modal").modal "hide"
