define [
    "underscore", "markdown"
    "views/proto/common"
    "models/current-user"
    "text!templates/helper/textarea.html"
], (_, markdown, Common, currentUser, html) ->

    previewMode = undefined
    cachedText = undefined

    class extends Common
        template: _.template html

        @active: ->
            cachedText? and cachedText.length > 0

        events:
            "keydown textarea": "preEdit"
            "keyup textarea": "postEdit"
            "click .helper-textarea-show-preview": -> @switchPreview(true)
            "click .helper-textarea-hide-preview": -> @switchPreview(false)
            "click .helper-textarea-show-help": "toggleHelp"

        reveal: (text) ->
            @$el.show()
            @setValue(text)
            $("textarea").trigger "autosize"
            if text and text.length
                len = text.length * 2 # http://stackoverflow.com/a/1675345/137062
                @$("textarea")[0].setSelectionRange len, len
            @updatePreview()

        value: -> @$("textarea").val()
        setValue: (val) ->
            @$("textarea").val(val)
            cachedText = val
            return

        hide: ->
            cachedText = undefined
            @$el.hide()

        disable: -> @$("textarea").prop "disabled", true
        enable: -> @$("textarea").prop "disabled", false
        disabled: -> not @$el.is(":visible") or @$("textarea").prop("disabled")
        clear: -> @setValue("")
        focus: -> @$("textarea").focus()

        initialize: ->
            super
            previewMode = !!( currentUser.getSetting("preview-mode") - 0 ) # casting string to boolean

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

        toggleHelp: ->
            if not @popoverInitialized
                # for some reason this code doesn't work from render()
                @$(".helper-textarea-show-help").popover(
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
                        <a href="#" onclick="window.open('/about/syntax', '_blank')" class="helper-textarea-cheatsheet-link">Full cheat sheat &rarr;</a>
                      </div>
                    """
                    container: "body"
                    trigger: "manual"
                )
                @popoverInitialized = true
            @$(".helper-textarea-show-help").popover "toggle"
            return false

        destroyHelp: ->
            @popoverInitialized = false
            @$(".helper-textarea-show-help").popover "destroy"

        remove: ->
            cachedText = undefined
            @destroyHelp()
            super

        preEdit: (e) ->
            if e.ctrlKey and (e.which is 13 or e.which is 10)
                @trigger "save", @value()
            else if e.which is 27
                @trigger "cancel"
            return false if @disabled()

        postEdit: (e) ->
            return false if @disabled()
            cachedText = @value()
            @updatePreview()
            @trigger "edit"

        render: ->
            @destroyHelp()
            super
            @$("textarea").autosize append: "\n"

        serialize: ->
            placeholder: @options.placeholder
            previewMode: previewMode

        setRealm: (realm) ->
            @options.realm = realm
            @updatePreview()
