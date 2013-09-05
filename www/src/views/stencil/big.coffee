define [
    "underscore"
    "views/proto/common"
    "models/shared-models", "models/current-user"
    "views/helper/textarea"
    "views/helper/markdown"
    "text!templates/stencil/big.html"
], (_, Common, sharedModels, currentUser, Textarea, Markdown, html) ->
    class extends Common
        template: _.template html

        events:
            "click .edit": "startEdit"
            "click .post-edit-controls .save": "saveEdit"
            "click .post-edit-controls .cancel": "closeEdit"
            "click .stencil-big-tabs div._icon": "switch"
            "keyup input": "edit"

        switch: (e) ->
            # FIXME - evil, evil copypaste (see also: user/big, realm/tabs)
            t = $(e.target).closest("._icon")
            @tab = t.attr "data-tab"

            @trigger "switch", tab: @tab
            t.closest("ul").find("._active").removeClass "_active"
            t.addClass "_active"

        subviews:
            ".description-edit-sv": ->
                new Textarea
                    realm: @model.get("realm")
                    placeholder: "Stencil description"
            ".description-sv": ->
                new Markdown
                    realm: @model.get("realm")
                    text: @model.get("description")

        description: -> @subview(".description-edit-sv")

        initialize: ->
            @tab = @options.tab || 'comments'
            super
            @listenTo @model, "change", @render
            @listenTo @model, "change:description", ->
                @subview(".description-sv").setText @model.get("description")

        render: ->
            # wait for realm data - copy-pasted from views/quest/add
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @render()
                return
            super
            @listenTo @description(), "save", @saveEdit
            @listenTo @description(), "cancel", @closeEdit

        serialize: ->
            params = super

            params.currentUser = currentUser.get("login")
            # TODO - move to model.serialize?
            realm = sharedModels.realms.findWhere { id: @model.get("realm") }
            params.isKeeper = realm.isKeeper()
            params.tab = @tab
            params

        startEdit: ->
            @$("._edit").show()
            @$("._editable").hide()

            @$("[name=name]").val @model.get("name")
            @$("[name=name]").focus()

            tags = @model.get("tags") or []
            @$("[name=tags]").val tags.join(", ")

            @validateForm()
            mixpanel.track "start edit", entity: "stencil"
            @description().reveal @model.get("description")

        validateForm: ->
            ok = true
            if @$("[name=name]").val().length
                @$("[name=name]").parent().removeClass "error"
            else
                @$("[name=name]").parent().addClass "error"
                ok = false

            # copy-pasted from views/quest/big
            cg = @$("[name=tags]").parent() # control-group
            if @model.validateTagline(cg.find("input").val())
                cg.removeClass "error"
                cg.find("input").tooltip "hide"
            else
                unless cg.hasClass("error")
                    cg.addClass "error"

                    oldFocus = $(":focus")
                    cg.find("input").tooltip "show"
                    $(oldFocus).focus()
                ok = false

            if ok
                @$(".post-edit-controls .save").removeClass "disabled"
            else
                @$(".post-edit-controls .save").addClass "disabled"
            ok

        saveEdit: =>
            # so, we're using DOM data to cache validation status... this is a slippery slope.
            return if @$(".post-edit-controls .save").hasClass("disabled")

            name = @$("[name=name]").val()
            tagline = @$("[name=tags]").val()
            points = @$(".stencil-big-reward-pick .active").attr "data-points"

            @model.save
                name: name
                description: @description().value()
                tags: @model.tagline2tags(tagline)
                points: points
            @closeEdit()

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()

        closeEdit: =>
            @$("._edit").hide()
            @$("._editable").show()
            @description().hide()

        features: ['timeago', 'tooltip']
