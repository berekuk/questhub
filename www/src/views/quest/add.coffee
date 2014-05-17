define [
    "underscore", "jquery", "react"
    "views/proto/common"
    "views/helper/textarea", "views/quest/add/realm-helper"
    "models/shared-models", "models/quest"
    "text!templates/quest/add.html"
    "bootstrap"
], (_, $, React, Common, Textarea, RealmHelper, sharedModels, QuestModel, html) ->
    class extends Common
        template: _.template(html)

        activated: false # look below for activate() override

        activeMenuItem: -> "new-quest"
        pageTitle: -> "New quest"

        events:
            "click ._go": "submit"
            "click ._cancel": "close"
            "click .quest-add-close": "close"
            "keyup [name=name]": "nameEdit"
            "keyup [name=tags]": "tagsEdit"
            "change [name=realm]": "switchRealmSelect"
            "click .quest-add-realm-list li a": "switchRealmList"

        subviews:
            ".description-sv": ->
                new Textarea
                    realm: @getRealmId()
                    placeholder: "Quest details are optional. You can always add them later."

        description: -> @subview(".description-sv")

        initialize: ->
            super
            _.bindAll this
            @activate()

        setRealmList: (realm) ->
            @$(".quest-add-realm-list ul li").removeClass("active")
            @$(".quest-add-realm-list ul li[data-realm=#{realm}]").addClass("active")

        setRealmSelect: (realm) ->
            @$(".quest-add-realm-select :selected").prop "selected", false
            @$(".quest-add-realm-select [value=#{realm}]").prop "selected", true
            @$("[name=name]").focus()

        switchRealmList: (e) ->
            id = $(e.target).closest("a").parent().attr("data-realm")
            @setRealmList id
            @setRealmSelect id
            @updateRealm id
            @validate()
            @$("[name=name]").focus()

        switchRealmSelect: ->
            id = @$(".quest-add-realm-select :selected").val()
            @setRealmList id
            @updateRealm id
            @validate()

        disable: ->
            @$("._go").addClass "disabled"
            @enabled = false

        enable: ->
            @$("._go").removeClass "disabled"
            @enabled = true
            @submitted = false

        validate: (options) ->
            @$("._go").tooltip("destroy")
            qt = @$(".quest-tags-edit")
            tagLine = @$("[name=tags]").val()
            if QuestModel::validateTagline(tagLine)
                qt.removeClass "error"
                qt.find("input").tooltip "hide"
            else
                unless qt.hasClass("error")
                    qt.addClass "error"

                    # .tooltip() loses focus for some reason, so we have to save it and restore
                    #
                    # Note that animation for this tooltip is disabled, to avoid race conditions.
                    # I'm not sure how to fix them...
                    # http://ricostacruz.com/backbone-patterns/#animation_buffer talks about animation buffers,
                    # but I don't know how to integrate it with bootstrap-tooltip.js code - it doesn't accept any "onShown" callback.
                    oldFocus = $(":focus")
                    qt.find("input").tooltip "show"
                    $(oldFocus).focus()
                @disable()
                return
            if @submitted or not @getName()
                @disable()
                return
            if not @getRealmId()
                @$("._go").tooltip()
                @disable()
                return
            @enable()

        nameEdit: (e) ->
            @validate()
            @optimizeNameFont()
            @checkEnter e

        tagsEdit: (e) ->
            @validate()
            @checkEnter e

        optimizeNameFont: ->
            input = @$("[name=name]")
            testerId = "#quest-add-test-span"
            tester = $(testerId)
            unless tester.length
                tester = $("<span id=\"#{testerId}\"></span>")
                tester.css "display", "none"
                tester.css "fontFamily", input.css("fontFamily")
                @$el.append tester
            tester.css "fontSize", input.css("fontSize")
            tester.css "lineHeight", input.css("lineHeight")
            tester.text input.val()
            if tester.width() > input.width()
                newFontSize = parseInt(input.css("fontSize")) - 1
                if newFontSize > 14
                    newFontSize += "px"
                    input.css "fontSize", newFontSize
                    input.css "lineHeight", newFontSize

        getName: -> @$("[name=name]").val()
        getDescription: -> @description().value()
        getRealmId: -> @_realmId
        getRealm: -> @_realm

        getTags: ->
            tagLine = @$("[name=tags]").val()
            QuestModel::tagline2tags tagLine

        setRealm: (id) ->
            @_realmId = id
            if id
                @_realm = sharedModels.realms.findWhere id: id
            else
                @_realm = null

        rerenderRealmHelper: ->
            React.renderComponent(RealmHelper(model: @getRealm()), @$(".realm-sv")[0])

        updateRealm: (id) ->
            @setRealm id
            @rerenderRealmHelper()
            @$(".quest-add-sidebar").removeClass("quest-add-realm-unpicked")
            @description().setRealm(id)

        serialize: ->
            params = super
            params.realms = sharedModels.realms.toJSON()
            params.selectedRealm = @getRealmId()
            params

        activate: ->
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @activate()
                return

            @model = new QuestModel()
            if @options.cloned_from
                @model.set
                    name: @options.cloned_from.get("name")
                    description: @options.cloned_from.get("description")
                    tags: @options.cloned_from.get("tags")
                    realm: @options.cloned_from.get("realm")
                    cloned_from: @options.cloned_from.id

            id = @model.get("realm") || @options.realm
            unless id
                userRealms = sharedModels.currentUser.get("realms")
                id = userRealms[0] if userRealms and userRealms.length is 1
            @setRealm id

            super

        form2model: ->
            @model.set
                name: @getName()
                realm: @getRealmId()
                description: @description().value()
                tags: @getTags()

        render: ->
            @form2model() if @rendered # don't want to lose data on accidental re-render
            super
            @rerenderRealmHelper()
            @rendered = true
            @setRealmList @getRealmId()
            @setRealmSelect @getRealmId()

            @$(".btn-group").button()
            @$(".icon-spinner").hide()
            @submitted = false
            @validate()

            @description().reveal @model.get("description") || ""
            window.setTimeout =>
                @$("[name=name]").focus()
            , 100


        submit: ->
            return unless @enabled

            @form2model()

            @model.save {},
                success: =>
                    Backbone.trigger "pp:quest-add", @model
                    @close()

            ga "send", "event", "quest", "add"
            mixpanel.track "add quest"
            @submitted = true
            @$(".icon-spinner").show()
            @validate()

        checkEnter: (e) ->
            @submit() if e.keyCode is 13

        close: ->
            Backbone.history.navigate "/", trigger: true, replace: true
