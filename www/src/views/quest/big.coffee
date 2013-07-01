define ["underscore", "jquery", "markdown", "backbone", "views/proto/common", "views/quest/like", "models/current-user", "bootbox", "text!templates/quest-big.html"], (_, $, markdown, Backbone, Common, Like, currentUser, bootbox, html) ->
    "use strict"
    Common.extend
        template: _.template(html)
        events:
            "click .quest-join": "join"
            "click .delete": "destroy"
            "click .edit": "startEdit"
            "click button.save": "saveEdit"
            "keyup input": "edit"
            "keyup [name=description]": "edit"
            mouseenter: (e) ->
                @subview(".likes-subview").showButton()

            mouseleave: (e) ->
                @subview(".likes-subview").hideButton()

        subviews:
            ".likes-subview": ->
                new Like(
                    model: @model
                    hidden: true
                )

        afterInitialize: ->
            @listenTo @model, "change", @render

        join: -> @model.join()

        startEdit: ->
            return  unless @model.isOwned()
            @$(".quest-big-edit").show()
            @backup = _.clone(@model.attributes)
            tags = @model.get("tags") or []
            @$("[name=tags]").val tags.join(", ")
            @$("[name=name]").val @model.get("name")
            @$("[name=description]").val(@model.get("description")).trigger "autosize"
            @validateForm()
            @$(".quest-big-editable").hide()
            @$("[name=name]").focus()
            @updateDescriptionPreview()

        updateDescriptionPreview: ->
            text = @$("[name=description]").val()
            preview = @$(".quest-big-description-preview")
            if text
                preview.show()
                preview.find("._content").html markdown(text, @model.get("realm"))
            else
                preview.hide()


        # check if edit form is valid, and also highlight invalid fiels appropriately
        validateForm: ->
            ok = true
            if @$("[name=name]").val().length
                @$("[name=name]").parent().removeClass "error"
            else
                @$("[name=name]").parent().addClass "error"
                ok = false
            cg = @$("[name=tags]").parent() # control-group
            if @model.validateTagline(cg.find("input").val())
                cg.removeClass "error"
                cg.find("input").tooltip "hide"
            else
                unless cg.hasClass("error")
                    cg.addClass "error"

                    # copy-pasted from views/quest/add, TODO - refactor
                    oldFocus = $(":focus")
                    cg.find("input").tooltip "show"
                    $(oldFocus).focus()
                ok = false
            if ok
                @$("button.save").removeClass "disabled"
            else
                @$("button.save").addClass "disabled"
            ok

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()
            else @updateDescriptionPreview()  if target.is("textarea")

        closeEdit: ->
            @$(".quest-big-edit").hide()
            @$(".quest-big-editable").show()

        saveEdit: ->

            # so, we're using DOM data to cache validation status... this is a slippery slope.
            return  if @$("button.save").hasClass("disabled")

            # form is validated already by edit() method
            name = @$("[name=name]").val()
            description = @$("[name=description]").val()
            tagline = @$("[name=tags]").val()
            @model.save
                name: name
                description: description
                tags: @model.tagline2tags(tagline)

            @closeEdit()

        destroy: ->
            that = this
            bootbox.confirm "Quest and all comments will be destroyed permanently. Are you sure?", (result) ->
                if result
                    that.model.destroy success: (model, response) ->
                        Backbone.history.navigate "/",
                            trigger: true


        serialize: ->
            params = @model.serialize()
            params.currentUser = currentUser.get("login")
            params.meGusta = _.contains(params.likes or [], params.currentUser)
            params.showStatus = true
            params

        afterRender: ->
            @$("[name=description]").autosize append: "\n"

        features: ["tooltip", "timeago"]
