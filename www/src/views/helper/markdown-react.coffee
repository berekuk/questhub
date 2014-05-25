define [
    "jquery", "react", "markdown"
    "vendors/pagedown/Markdown.Sanitizer"
], ($, React, markdown, VendorMarkdown) ->
    {div,i} = React.DOM

    React.createClass
        displayName: "Markdown"
        propTypes:
            text: React.PropTypes.string.isRequired
            realm: React.PropTypes.string
            editable: React.PropTypes.bool
            syncing: React.PropTypes.bool
            onTextChange: React.PropTypes.func

        getDefaultProps: ->
            realm: ""
            editable: false
            syncing: false

        render: ->
            div
                className: "md #{if @props.editable then "md-editable" else ""}"
                if @props.syncing
                    div className: "md-syncing",
                        i className: "icon-spinner icon-spin"
                div
                    dangerouslySetInnerHTML:
                        __html: markdown @props.text || "", @props.realm

        markTask: (e) ->
            return unless @props.editable
            target = $(e.target).prev()
            classes = target[0].className.split /\s+/
            for c in classes
                groups = c.match(/^task(\d+)/)
                continue unless groups
                taskId = groups[1]
                converter = new VendorMarkdown.getSanitizingConverter()
                newText = converter.markTask @props.text, taskId
                break
            # if onTextChange is not set, this will fail, but it means we have a bug in our code anyway
            @props.onTextChange newText


        installEvents: ->
            $el = $(@getDOMNode())
            $el.find("input[type=checkbox]:checked").after('<i class="md-task-icon icon-check"></i>')
            $el.find("input[type=checkbox]:not(:checked)").after('<i class="md-task-icon icon-check-empty"></i>')

            if @props.editable
                $el.find(".md-task-icon").on "click", @markTask # TODO - .off
            else
                $el.find("input[type=checkbox]").prop('disabled', true)

        uninstallEvents: ->
            $(@getDOMNode()).off "click"

        componentDidMount: -> @installEvents()
        componentDidUpdate: -> @installEvents()
        componentWillUnmount: -> @uninstallEvents()
