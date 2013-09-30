define [
    "underscore", "jquery", "markdown"
    "vendors/pagedown/Markdown.Sanitizer"
], (_, $, markdown, VendorMarkdown) ->
    class extends Backbone.View

        events:
            "click .md-task-icon": "markTask"

        render: ->
            @$el.html """<div class="md #{if @options.editable then "md-editable" else ""}">#{markdown(@options.text || "", @options.realm)}</div>"""
            @$("input[type=checkbox]").prop('disabled', true) unless @options.editable
            @$("input[type=checkbox]:checked").after('<i class="md-task-icon icon-check"></i>')
            @$("input[type=checkbox]:not(:checked)").after('<i class="md-task-icon icon-check-empty"></i>')
            @renderSyncing() if @syncing

        # doesn't re-render
        setRealm: (id) ->
            @options.realm = id

        setText: (text) ->
            @options.text = text
            @render()

        getText: -> @options.text

        markTask: (e) ->
            return unless @options.editable
            target = $(e.target).prev()
            classes = target[0].className.split /\s+/
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
