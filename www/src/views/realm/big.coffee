define [
  "views/proto/common"
  "views/realm/controls", "views/realm/tabs"
  "views/helper/textarea"
  "text!templates/realm/big.html"
], (Common, RealmControls, RealmTabs, Textarea, html) ->
    class extends Common
        template: _.template(html)

        events:
            "click .edit": "startEdit"
            "click button.cancel": "closeEdit"
            "click button.save": "saveEdit"
            "keyup input": "edit"

        subviews:
            ".controls-subview": ->
                new RealmControls model: @model
            ".tabs-sv": ->
                new RealmTabs tab: @tab, model: @model
            ".description-sv": ->
                new Textarea
                    realm: @model.get("realm")
                    placeholder: "Realm description"

        description: -> @subview(".description-sv")

        initialize: ->
            @tab = @options.tab || 'stencils'
            super
            @listenTo @model, "change", @render

        startEdit: ->
            @$("._edit").show()
            @$("._editable").hide()
            @$("[name=name]").val @model.get("name")
            @$("[name=name]").focus()
            mixpanel.track "start edit", entity: "realm"
            @description().reveal @model.get("description")

        closeEdit: ->
            @$("._edit").hide()
            @$("._editable").show()
            @description().hide()

        edit: (e) ->
            target = $(e.target)
            if @validateForm() and e.which is 13 and target.is("input")
                @saveEdit()
            else if e.which is 27
                @closeEdit()

        validateForm: ->
            true # TODO
            if @$("[name=name]").val().length
                @$("[name=name]").parent().removeClass "error"
            else
                @$("[name=name]").parent().addClass "error"
                ok = false

        saveEdit: =>
            name = @$("[name=name]").val()
            @model.save
                name: name
                description: @description().value()
            @closeEdit()

        render: ->
            super
            @listenTo @description(), "save", @saveEdit
            @listenTo @description(), "cancel", @closeEdit
            @listenTo @subview(".tabs-sv"), "switch", (params) =>
                @trigger "switch", params
