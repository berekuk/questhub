define [
    "underscore", "jquery"
    "views/proto/common"
    "views/helper/textarea"
    "models/shared-models", "models/quest"
    "text!templates/quest/add.html"
    "bootstrap", "jquery.autosize"
], (_, $, Common, Textarea, sharedModels, QuestModel, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click ._go": "submit"
            "click .quest-add-close": "remove"
            "click .quest-add-backdrop": "remove"
            "keyup [name=name]": "nameEdit"
            "keyup [name=tags]": "tagsEdit"
            "change [name=realm]": "switchRealmSelect"
            "click .quest-add-realm-list li a": "switchRealmList"

        subviews:
            ".description-sv": ->
                new Textarea
                    realm: @getRealm()
                    placeholder: "Quest details are optional. You can always add them later."
        description: -> @subview(".description-sv")

        initialize: ->
            super
            _.bindAll this
            $("#modal-storage").append @$el
            @render()

        setUpic: (id) ->
            realm = sharedModels.realms.findWhere id: id
            $('.quest-add-realm-pic-box').html('')
            $('.quest-add-realm-pic-box').append $('<img src="' + realm.get("pic") + '">')


        setRealmList: (realm) ->
            @$(".quest-add-realm-list ul li").removeClass("active")
            @$(".quest-add-realm-list ul li[data-realm=#{realm}]").addClass("active")

        setRealmSelect: (realm) ->
            @$(".quest-add-realm-select :selected").prop "selected", false
            @$(".quest-add-realm-select [value=#{realm}]").prop "selected", true
            @$("[name=name]").focus()

        switchRealmList: (e) ->
            realm = $(e.target).closest("a").parent().attr("data-realm")
            @setRealmList realm
            @setRealmSelect realm
            @setUpic realm
            @validate()
            @$("[name=name]").focus()

        switchRealmSelect: ->
            realm = @$(".quest-add-realm-select :selected").val()
            @setRealmList realm
            @validate()

        disable: ->
            @$("._go").addClass "disabled"
            @enabled = false

        enable: ->
            @$("._go").removeClass "disabled"
            @enabled = true
            @submitted = false

        validate: (options) ->
            if not @getRealm()
                @disable()
                return
            if @submitted or not @getName()
                @disable()
                return
            @enable()
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
        getDescription: -> @$("[name=description]").val()
        getRealm: ->
            selectRealm = @$(".quest-add-realm-select [name=realm] :selected").val()
            listRealm = @$(".quest-add-realm-list li.active").attr("data-realm")
            return selectRealm || listRealm

        getTags: ->
            tagLine = @$("[name=tags]").val()
            QuestModel::tagline2tags tagLine

        defaultRealm: ->
            defaultRealm = @options.realm
            unless defaultRealm
                userRealms = sharedModels.currentUser.get("realms")
                defaultRealm = userRealms[0] if userRealms and userRealms.length is 1
            return defaultRealm

        serialize: ->
            realms: sharedModels.realms.toJSON()
            defaultRealm: @defaultRealm()


        render: ->
            unless sharedModels.realms.length
                sharedModels.realms.fetch().success => @render()
                return

            super

            defaultRealm = @defaultRealm()
            @setUpic defaultRealm if defaultRealm

            @$("[name=name]").focus()

            @$(".btn-group").button()
            @$(".icon-spinner").hide()
            @submitted = false
            @validate()

            window.getComputedStyle(@$(".quest-add-backdrop")[0]).getPropertyValue("opacity")
            @$(".quest-add-backdrop").addClass "quest-add-backdrop-fade"
            @description().reveal ""


        submit: ->
            return unless @enabled
            model_params =
                name: @getName()
                realm: @getRealm()

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
            @remove()

        remove: ->
            super
            @trigger "remove"
