define [
    "underscore", "jquery"
    "views/proto/common"
    "views/helper/markdown"
    "models/current-user"
    "text!templates/helper/textarea.html"
    "models/quest"
], (_, $, Common, Markdown, currentUser, html, QuestModel) ->

    previewMode = undefined
    cachedText = {}
    cachedLinks = {}

    class extends Common
        template: _.template html

        @active: ->
            !!(_.size _.find cachedText, (v) -> v? and v.length > 20)

        events:
            "keydown textarea": "preEdit"
            "input textarea": "postEdit"
            "click textarea": "autosuggest"
            "click .helper-textarea-show-preview": -> @switchPreview(true)
            "click .helper-textarea-hide-preview": -> @switchPreview(false)
            "click .helper-textarea-show-help": "toggleHelp"

        # useful in case of accidental re-renders, we're calling it from reveal() and from render()
        restoreFromCache: ->
            if cachedText[@cid]
                @setValue cachedText[@cid]
                return true
            return false

        reveal: (text) ->
            @$el.show()
            @$("textarea").autosize append: "\n"
            @restoreFromCache() or @setValue(text)
            if text and text.length
                len = text.length * 2 # http://stackoverflow.com/a/1675345/137062
                @$("textarea")[0].setSelectionRange len, len

        value: -> @$("textarea").val()
        setValue: (val) ->
            @$("textarea").val(val)
            cachedText[@cid] = val
            @updatePreview()
            @$("textarea").trigger "autosize"
            return

        hide: ->
            delete cachedText[@cid]
            @$el.hide()

        disable: -> @$("textarea").prop "disabled", true
        enable: -> @$("textarea").prop "disabled", false
        disabled: -> not @$el.is(":visible") or @$("textarea").prop("disabled")
        clear: -> @setValue("")
        focus: -> @$("textarea").focus()

        initialize: ->
            super
            previewMode = !!( currentUser.getSetting("preview-mode") - 0 ) # casting string to boolean
            @on 'detach-subview', @selfDestruct, @

            $("body").on "click", @blurHelp
            $("body").on "click", @hideSuggest

        subviews:
            ".helper-textarea-preview ._content": ->
                new Markdown
                    realm: @options.realm

        md: -> @subview(".helper-textarea-preview ._content")

        preview: -> @$(".helper-textarea-preview")
        switchPreview: (value) ->
            previewMode = value
            currentUser.setSetting "preview-mode", 0 + previewMode
            @updatePreview()
            @focus()
            @$(".helper-textarea-show-preview").toggle(!previewMode)
            @$(".helper-textarea-hide-preview").toggle(previewMode)

        updatePreview: ->
            text = @value()
            @$el.toggleClass "helper-textarea-empty", !text

            preview = @preview()

            if text and previewMode
                preview.show()
                @md().setText(text)
            else
                preview.hide()

        helpLink: -> @$(".helper-textarea-show-help")
        helpPopover: -> @$(".popover")

        blurHelp: (e) =>
            if !@helpLink().is(e.target) and @helpLink().has(e.target).length == 0 and @helpPopover().has(e.target).length == 0
                @helpLink().popover('hide')

        initPopover: ->
            @helpLink().popover(
                placement: "top"
                title: "Formatting cheat sheet"
                html: true
                content: """
                  <div class="helper-textarea-cheatsheet">
                    <code>*Italic*</code><br>
                    <code>**Bold**</code><br>
                    <code># Header1</code><br>
                    <code>## Header2</code><br>
                    <code>&gt; Blockquote</code><br>
                    <code>@login</code><br>
                    <code>[Link title](Link URL)</code><br>
                    <a href="/about/syntax" target="_blank" class="helper-textarea-cheatsheet-link">Full cheat sheat &rarr;</a>
                  </div>
                """
                container: @$el
                trigger: "manual"
            )

        toggleHelp: ->
            @helpLink().popover "toggle"
            return false

        selfDestruct: ->
            delete cachedText[@cid]
            @$("textarea").popover "destroy"
            @helpLink().popover "destroy"

        remove: ->
            $("body").off "click", @blurHelp # avoiding event handler leaks
            @selfDestruct()
            super

        preEdit: (e) ->
            if e.ctrlKey and (e.which is 13 or e.which is 10)
                @trigger "save", @value()
            else if e.which is 27
                @trigger "cancel"
            return false if @disabled()

        postEdit: (e) ->
            return false if @disabled()
            cachedText[@cid] = @value()
            @autosuggest()
            @updatePreview()
            @trigger "edit"

        autosuggest: =>
            @hideSuggest()
            @checkQuestLinks()

        render: ->
            @helpLink().popover "destroy"
            super
            @initPopover()
            @restoreFromCache() or @updatePreview()
            if @$el.is(":visible")
                @$("textarea").autosize append: "\n"

        serialize: ->
            placeholder: @options.placeholder
            previewMode: previewMode

        setRealm: (realm) ->
            @options.realm = realm
            @updatePreview()

        hideSuggest: (e) =>
            textarea = @$("textarea")
            if (!e || e.target != textarea[0])
                textarea.popover("destroy")

        suggestEdit: (start, end, edit, label) ->
            # Display suggestion
            @$("textarea").popover(
                title: "Insert link with quest title?"
                content: '<button class="btn helper-textarea-suggest">' +
                    label + '</button>'
                html: true
                placement: "bottom"
                trigger: "manual"
            ).popover("show")

            # Insert suggestion on button click
            @$(".helper-textarea-suggest").on "click", =>
                val = cachedText[@cid]
                newVal = val.substring(0, start) + edit + val.substring(end)
                @setValue(newVal)

        wordAtPoint: ->
            cursor = @$("textarea").prop "selectionStart"
            text = cachedText[@cid]
            start = text.lastIndexOf(' ', cursor)
            if (start == cursor)
                start = text.lastIndexOf(' ', cursor - 1)
            start += 1
            end = text.indexOf(' ', cursor)
            if (end == -1)
                end = text.length
            [text.substring(start, end), start, end]

        checkQuestLinks: ->
            [word, start, end] = @wordAtPoint()
            if (!word)
                return
            display = =>
                questName = cachedLinks[word]
                @suggestEdit(start, end,
                    "[" + questName + "](" + word + ")", questName)
            if word of cachedLinks
                display()
            else
                questRe = "://" + location.host + "/.*/?quest/([a-z0-9]{24,})$"
                match = word.match(questRe)
                if (match)
                    model = new QuestModel _id: match[1]
                    model.fetch success: =>
                        cachedLinks[word] = model.get "name"
                        #[newWord] = @wordAtPoint()
                        #if (newWord == word)
                        #    display()
                        display() # display even if cursor moved
