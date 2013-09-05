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
            "keyup [name=tags]": "tagsEdit"

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
        getPoints: -> @$(".stencil-add-reward .active").attr "data-points"

        getTags: ->
            tagLine = @$("[name=tags]").val()
            Model::tagline2tags tagLine

        validate: (options) ->
            qt = @$(".stencil-tags-edit")
            tagLine = @$("[name=tags]").val()
            if Model::validateTagline(tagLine)
                qt.removeClass "error"
                qt.find("input").tooltip "hide"
            else
                unless qt.hasClass("error")
                    qt.addClass "error"

                    oldFocus = $(":focus")
                    qt.find("input").tooltip "show"
                    $(oldFocus).focus()
                @disable()
                return
            if @submitted or not @getName()
                @disable()
                return
            @enable()

        nameEdit: (e) ->
            @validate()
            @checkEnter e

        tagsEdit: (e) ->
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
            params.points = @getPoints()
            tags = @getTags()
            params.tags = tags if tags

            mixpanel.track "add stencil"
            model = new Model()
            model.save params,
                success: =>
                    Backbone.trigger "pp:stencil-add", model
                    @$(".modal").modal "hide"
            @$(".icon-spinner").show()
            @validate()
