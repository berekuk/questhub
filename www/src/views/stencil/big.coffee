define [
    "underscore", "markdown"
    "views/proto/common"
    "models/shared-models"
    "text!templates/stencil/big.html"
], (_, markdown, Common, sharedModels, html) ->
    class extends Common
        template: _.template html
        serialize: -> @model.serialize()
        features: ["timeago"]

        events:
            "click .edit": "startEdit"
            "click button.save": "saveEdit"
            "keyup input": "edit"
            "keyup [name=description]": "edit"

        initialize: ->
            super
            @listenTo @model, "change", @render

        render: ->
            # wait for realm data - copy-pasted from views/quest/add
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @render()
                return
            super

        # FIXME - copy-pasted from view/stencil/overview, move to model?
        serialize: ->
            params = super
            params.currentUser = sharedModels.currentUser.get "login"

            realm = sharedModels.realms.findWhere { id: @model.get("realm") }
            params.isKeeper = (params.currentUser && realm.get("keepers") && _.contains(realm.get("keepers"), params.currentUser))
            params

        startEdit: ->
            @$("._edit").show()
            @$("._editable").hide()
            @$("[name=name]").val @model.get("name")
            @$("[name=description]").val(@model.get("description")).trigger "autosize"
            @$("[name=name]").focus()
            @validateForm()
            @updateDescriptionPreview()

        validateForm: ->
            ok = true
            if @$("[name=name]").val().length
                @$("[name=name]").parent().removeClass "error"
            else
                @$("[name=name]").parent().addClass "error"
                ok = false

            if ok
                @$("button.save").removeClass "disabled"
            else
                @$("button.save").addClass "disabled"
            ok

        updateDescriptionPreview: ->
            text = @$("[name=description]").val()
            preview = @$(".js-stencil-big-description-preview")
            if text
                preview.show()
                preview.find("._content").html markdown(text, @model.get("realm"))
            else
                preview.hide()

        saveEdit: ->
            # so, we're using DOM data to cache validation status... this is a slippery slope.
            return if @$("button.save").hasClass("disabled")

            # form is validated already by edit() method
            name = @$("[name=name]").val()
            description = @$("[name=description]").val()
            @model.save
                name: name
                description: description
            @closeEdit()

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()
            else @updateDescriptionPreview() if target.is("textarea")

        closeEdit: ->
            @$("._edit").hide()
            @$("._editable").show()
