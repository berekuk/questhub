define [
    "underscore", "jquery", "markdown"
    "views/proto/common"
    "models/current-user"
    "text!templates/helper/textarea.html"
], (_, $, markdown, Common, currentUser, html) ->

    previewMode = undefined
    cachedText = {}

    class extends Common
        template: _.template html

        @active: ->
            !!(_.size _.find cachedText, (v) -> v? and v.length > 20)

        events:
            "keydown textarea": "preEdit"
            "keyup textarea": "postEdit"
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
                preview.find("._content").html markdown(text, @options.realm)
            else
                preview.hide()

        helpLink: -> @$(".helper-textarea-show-help")
        helpPopover: -> @$(".popover")

        blurHelp: (e) =>
            if !@helpLink().is(e.target) and @helpLink().has(e.target).length == 0 and @helpPopover().has(e.target).length == 0
                @helpLink().popover('hide')

        toggleHelp: ->
            if not @popoverInitialized
                # for some reason this code doesn't work from render()
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
                @popoverInitialized = true
            @helpLink().popover "toggle"

            return false

        destroyHelp: ->
            @popoverInitialized = false
            @helpLink().popover "destroy"

        selfDestruct: ->
            delete cachedText[@cid]
            @destroyHelp()

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
            @updatePreview()
            @trigger "edit"

        render: ->
            @destroyHelp()
            super
            @restoreFromCache() or @updatePreview()
            if @$el.is(":visible")
                @$("textarea").autosize append: "\n"

        serialize: ->
            placeholder: @options.placeholder
            previewMode: previewMode

        setRealm: (realm) ->
            @options.realm = realm
            @updatePreview()
