###

Lots of this code is copy-pasted from views/quest/add.coffee.

###
define [
    "underscore", "jquery"
    "views/proto/common"
    "models/stencil"
    "text!templates/stencil/add.html"
    "jquery.autosize"
], (_, $, Common, Model, html) ->
    class extends Common
        template: _.template html
        selfRender: true

        events:
            "click ._go": "submit"
            "keyup [name=name]": "nameEdit"

        initialize: ->
            super
            $("#modal-storage").append @$el
            @$(".modal").modal().on "shown", =>
                @$("[name=name]").focus()
            @$(".modal").modal().on "hidden", (e) =>
                return unless $(e.target).hasClass("modal")
                @remove()

        disable: ->
            @$("._go").addClass "disabled"
            @enabled = false

        enable: ->
            @$("._go").removeClass "disabled"
            @enabled = true
            @submitted = false

        getName: -> @$("[name=name]").val()
        getDescription: -> @$("[name=description]").val()

        validate: (options) ->
            if @submitted or not @getName()
                @disable()
                return
            @enable()

        nameEdit: (e) ->
            @validate()
            @checkEnter e

        checkEnter: (e) ->
            @submit() if e.keyCode is 13

        render: ->
            super
            @$(".icon-spinner").hide()
            @submitted = false
            @validate()
            @$("[name=description]").autosize append: "\n"

        submit: ->
            params =
                name: @getName()
                realm: @options.realm

            description = @getDescription()
            params.description = description if description

            mixpanel.track "add stencil"
            model = new Model()
            model.save params,
                success: =>
                    Backbone.trigger "pp:stencil-add", model
                    @$(".modal").modal "hide"
            @$(".icon-spinner").show()
            @validate()
