define [
    "underscore", "jquery", "markdown"
    "vendors/pagedown/Markdown.Sanitizer"
], (_, $, markdown, VendorMarkdown) ->
    class extends Backbone.View

        events:
            "click input.md-task": "markTask"

        render: ->
            @$el.html """<div class="md #{if @options.editable then "md-editable" else ""}">#{markdown(@options.text || "", @options.realm)}</div>"""
            @$("input[type=checkbox]").prop('disabled', true) unless @options.editable
            @renderSyncing() if @syncing

        setText: (text) ->
            @options.text = text
            @render()

        getText: -> @options.text

        markTask: (e) ->
            classes = e.target.className.split /\s+/
            for c in classes
                groups = c.match(/^task(\d+)/)
                continue unless groups
                taskId = groups[1]
                converter = new VendorMarkdown.getSanitizingConverter()
                @options.text = converter.markTask @options.text, taskId
                @render()
                @trigger "change"

        renderSyncing: ->
            @$(".md").prepend($("""
                <div class="md-syncing">
                    <i class="icon-spinner icon-spin"></i>
                </div>
            """))

        startSyncing: ->
            # TODO - double syncing (on two marked checkboxes) will stop showing progress while some syncing is still active
            # we need a counter
            return if @syncing
            @syncing = window.setTimeout =>
                @renderSyncing()
            , 300

        stopSyncing: ->
            if @syncing
                window.clearTimeout @syncing
                @$(".md-syncing").remove()
                @syncing = false
