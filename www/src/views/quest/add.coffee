define [
    "underscore", "jquery"
    "views/proto/common"
    "views/helper/textarea", "views/quest/add/realm-helper"
    "models/shared-models", "models/quest"
    "text!templates/quest/add.html"
    "bootstrap", "jquery.autosize"
], (_, $, Common, Textarea, RealmHelper, sharedModels, QuestModel, html) ->
    class extends Common
        template: _.template(html)

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
            ".realm-sv": ->
                new RealmHelper model: @getRealm()

        description: -> @subview(".description-sv")

        initialize: ->
            super
            _.bindAll this
            @render()

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

        initRealm: ->
            id = @options.realm
            unless id
                userRealms = sharedModels.currentUser.get("realms")
                id = userRealms[0] if userRealms and userRealms.length is 1
            @updateRealm id

        setRealm: (id) ->
            @_realmId = id
            if id
                @_realm = sharedModels.realms.findWhere id: id
            else
                @_realm = null

        updateRealm: (id) ->
            @setRealm id
            @rebuildSubview ".realm-sv"
            @subview(".realm-sv").render()
            @$(".quest-add-sidebar").removeClass("quest-add-realm-unpicked")
            @description().setRealm(id)

        serialize: ->
            realms: sharedModels.realms.toJSON()
            selectedRealm: @getRealmId()

        render: ->
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @render()
                return

            @initRealm()
            super
            @setRealmList @getRealmId()
            @setRealmSelect @getRealmId()

            @$(".btn-group").button()
            @$(".icon-spinner").hide()
            @submitted = false
            @validate()

            @$(".quest-add-backdrop").addClass "quest-add-backdrop-fade"
            @description().reveal ""
            window.setTimeout =>
                @$("[name=name]").focus()
            , 100


        submit: ->
            return unless @enabled
            model_params =
                name: @getName()
                realm: @getRealmId()

            description = @description().value()
            model_params.description = description if description
            tags = @getTags()
            model_params.tags = tags if tags
            model = new QuestModel()
            model.save model_params,
                success: @onSuccess

            ga "send", "event", "quest", "add"
            mixpanel.track "add quest"
            @submitted = true
            @$(".icon-spinner").show()
            @validate()

        checkEnter: (e) ->
            @submit() if e.keyCode is 13

        onSuccess: (model) ->
            Backbone.trigger "pp:quest-add", model
            @close()

        close: ->
            Backbone.history.navigate "/", trigger: true, replace: true
