define [
    "underscore", "backbone"
    "jquery", "bootbox"
    "views/proto/common"
    "views/quest/like"
    "views/helper/textarea", "views/helper/markdown"
    "models/current-user", "models/shared-models"
    "text!templates/quest/big.html"
], (_, Backbone, $, bootbox, Common, Like, Textarea, Markdown, currentUser, sharedModels, html) ->
    "use strict"
    class extends Common
        template: _.template(html)
        events:
            "click .quest-join": "join"
            "click .delete": "destroy"
            "click .edit": "startEdit"
            "click .post-edit-controls .save": "saveEdit"
            "click .post-edit-controls .cancel": "closeEdit"
            "click .quest-big-note-expand": "expandNote"
            "click .post-big-compose-comment": "composeComment"
            "keyup input": "edit"
            mouseenter: (e) -> @subview(".likes-subview").showButton()
            mouseleave: (e) -> @subview(".likes-subview").hideButton()

        _textSubview: (field) ->
            sv = new Markdown
                realm: @model.get("realm")
                text: @model.get(field)
                editable: @model.isOwned()
            sv.on "change", =>
                @model.set field, sv.getText()
                sv.startSyncing()
                @model.save().always ->
                    sv.stopSyncing()
            return sv

        subviews:
            ".likes-subview": ->
                new Like(
                    model: @model
                    hidden: true
                )
            ".description-edit-sv": ->
                new Textarea
                    realm: @model.get("realm")
                    placeholder: "Quest description"
            ".quest-big-description-sv": -> @_textSubview "description"
            ".quest-big-note-sv": -> @_textSubview "note"

        initialize: ->
            super
            @listenTo @model, "change:status", @render
            @listenTo @model, "change:description", ->
                @subview(".quest-big-description-sv").setText @model.get("description")
            @listenTo @model, "change:team", =>
                @rebuildSubview ".quest-big-description-sv" # make it non-editable if user left the team
                @rebuildSubview ".quest-big-note-sv"
                @render()

            # this doesn't usually happen
            @listenTo @model, "change:note", ->
                @subview(".quest-big-note-sv").setText @model.get("note")

        expandNote: ->
            @$(".quest-big-note").show()
            @$(".quest-big-note-expand").hide()

        join: -> @model.join()

        description: -> @subview(".description-edit-sv")

        startEdit: ->
            return unless @model.isOwned()
            @$(".quest-big-edit").show()
            tags = @model.get("tags") or []
            @$("[name=tags]").val tags.join(", ")
            @$("[name=name]").val @model.get("name")
            @validateForm()
            @$(".quest-big-editable").hide()
            @$("[name=name]").focus()
            mixpanel.track "start edit", entity: "quest"
            @description().reveal @model.get("description")

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
                @$(".post-edit-controls .save").removeClass "disabled"
            else
                @$(".post-edit-controls .save").addClass "disabled"
            ok

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()

        closeEdit: =>
            @$(".quest-big-edit").hide()
            @$(".quest-big-editable").show()
            @description().hide()
            @render()


        saveEdit: =>
            # so, we're using DOM data to cache validation status... this is a slippery slope.
            return if @$(".post-edit-controls .save").hasClass("disabled")

            # form is validated already by edit() method
            name = @$("[name=name]").val()
            tagline = @$("[name=tags]").val()
            @model.save
                name: name
                description: @description().value()
                tags: @model.tagline2tags(tagline)

            @closeEdit()

        destroy: ->
            bootbox.confirm "Quest and all comments will be destroyed permanently. Are you sure?", (result) =>
                if result
                    mixpanel.track "delete", entity: "quest"
                    @model.destroy success: (model, response) ->
                        Backbone.history.navigate "/",
                            trigger: true

        composeComment: ->
            @model.trigger "compose-comment"

        serialize: ->
            params = super
            params.currentUser = currentUser.get("login")
            params.meGusta = _.contains(params.likes or [], params.currentUser)
            params.showStatus = false
            params.realmData = sharedModels.realms.findWhere(id: @model.get("realm")).toJSON()
            params

        render: ->
            super
            @listenTo @description(), "save", @saveEdit
            @listenTo @description(), "cancel", @closeEdit

        features: ["tooltip", "timeago"]
