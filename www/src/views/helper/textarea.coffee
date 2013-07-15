define [
    "underscore", "markdown"
    "views/proto/common"
    "text!templates/helper/textarea.html"
], (_, markdown, Common, html) ->
    class extends Common
        template: _.template html

        events:
            "keydown textarea": "preEdit"
            "keyup textarea": "postEdit"

        reveal: (text) ->
            @$el.show()
            @$("textarea").val(text).trigger "autosize"
            @updatePreview()

        value: -> @$("textarea").val()

        hide: -> @$el.hide()

        updatePreview: ->
            text = @$("textarea").val()
            preview = @$(".helper-textarea-preview")
            if text
                preview.show()
                preview.find("._content").html markdown(text, @options.realm)
            else
                preview.hide()

        preEdit: (e) ->
            if e.ctrlKey and (e.which is 13 or e.which is 10)
                @trigger "save", @value()
            else if e.which is 27
                @trigger "cancel"

        postEdit: (e) ->
            if not @$el.is(":visible")
                return
            @updatePreview()

        render: ->
            super
            @$("textarea").autosize append: "\n"

        serialize: ->
            placeholder: @options.placeholder

