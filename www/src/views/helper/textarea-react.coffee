define [
    "jquery", "react"
    "views/helper/markdown-react"
    "views/helper/popover"
    "models/current-user"
    "jquery.autosize"
], ($, React, Markdown, Popover, currentUser) ->

    {div,a,i,textarea,code,br} = React.DOM

    # via https://github.com/andreypopp/react-textarea-autosize
    TextareaAutosize = React.createClass
        componentDidMount: ->
            $(@getDOMNode()).autosize append: "\n"
        componentWillUnmount: ->
            $(@getDOMNode()).trigger('autosize.destroy')
        render: ->
            return @transferPropsTo textarea disabled: !@props.enabled, @props.children

    MainArea = React.createClass
        displayName: "Textarea.MainArea"
        propTypes:
            placeholder: React.PropTypes.string
            preview: React.PropTypes.bool
            enabled: React.PropTypes.bool
            onTextChange: React.PropTypes.func
            onCancel: React.PropTypes.func
            onSubmit: React.PropTypes.func

        getInitialState: ->
            # unlike 'preview', 'help' is an internal state
            help: false

        focus: ->
            @refs.textarea.getDOMNode().focus()

        handleHelpToggle: ->
            @setState 'help': not @state.help

        repositionPopover: ->
            $el = $(@getDOMNode())
            target = $el.find(".helper-textarea-show-help")
            element = $el.find(".popover")

            attachPoint =
                left: target.offset().left + target.width() / 2
                top: target.offset().top

            auxOffset = left: -2, top: -11

            element.offset
                left: attachPoint.left - element.width() / 2 + auxOffset.left
                top: attachPoint.top - element.height() + auxOffset.top

        componentDidUpdate: ->
            if @state.help
                @repositionPopover()
                $("body").on "click", @hideHelp
            else
                $("body").off "click", @hideHelp

        hideHelp: ->
            return unless @state.help
            @setState help: false

        handleKeyDown: (event) ->
            if event.ctrlKey and (event.which is 13 or event.which is 10)
                @props.onSubmit?()
            else if event.which is 27
                @props.onCancel?()

        render: ->
            if @state.help
                popover = Popover
                    placement: 'top'
                    title: "Formatting cheat sheet"
                    div className: "helper-textarea-cheatsheet",
                        code(null, "*Italic*"), br()
                        code(null, "**Bold**"), br()
                        code(null, "# Header1"), br()
                        code(null, "## Header2"), br()
                        code(null, "> Blockquote"), br()
                        code(null, "@login"), br()
                        code(null, "[Link title](Link URL)"), br()
                        a href: "/about/syntax", target: "_blank",
                            "Full cheat sheat →"

            if @props.preview
                toggle = a
                    href:"#"
                    title: "Hide preview"
                    onClick: => @props.onPreviewToggle false
                    i className: "icon-caret-up"
            else
                toggle = a
                    href:"#"
                    title: "Show preview"
                    onClick: => @props.onPreviewToggle true
                    i className: "icon-caret-down"

            div
                className: "helper-textarea-main"
                TextareaAutosize
                    ref: "textarea"
                    placeholder: @props.placeholder
                    value: @props.text
                    enabled: @props.enabled
                    onChange: (event) => @props.onTextChange event.target.value
                    onKeyDown: @handleKeyDown
                div className: "helper-textarea-controls #{if !@props.text and !@state.help then "helper-textarea-controls-empty" else ""}",
                    a
                        href:"#"
                        className: "helper-textarea-show-help"
                        onClick: @handleHelpToggle
                        i className: "icon-question"
                    popover if @state.help
                    " "
                    toggle

    PreviewArea = React.createClass
        displayName: "Textarea.PreviewArea"

        render: ->
            div className: "helper-textarea-preview",
                div className: "_label",
                    "Preview"
                div className: "_content",
                    Markdown
                        realm: @props.realm
                        text: @props.text
                        editable: false


    React.createClass
        displayName: "Textarea"

        propTypes:
            text: React.PropTypes.string
            realm: React.PropTypes.string
            enabled: React.PropTypes.bool
            onTextChange: React.PropTypes.func
            onCancel: React.PropTypes.func
            onSubmit: React.PropTypes.func

        getDefaultProps: ->
            text: ""
            realm: ""
            enabled: true

        getInitialState: ->
            preview: !!( currentUser.getSetting("preview-mode") - 0 ) # casting string to boolean

        events:
            "keydown textarea": "preEdit"

        reveal: (text) ->
            @$el.show()
            @$("textarea").autosize append: "\n"
            @restoreFromCache() or @setValue(text)
            if text and text.length
                len = text.length * 2 # http://stackoverflow.com/a/1675345/137062
                @$("textarea")[0].setSelectionRange len, len

        handlePreviewToggle: (value) ->
            @setState preview: value
            currentUser.setSetting "preview-mode", 0 + value
            @refs.main.focus()

        render: ->
            div className: "helper-textarea",
                MainArea
                    ref: "main"
                    text: @props.text
                    placeholder: @props.placeholder
                    preview: @state.preview
                    enabled: @props.enabled
                    onPreviewToggle: @handlePreviewToggle
                    onTextChange: @props.onTextChange
                    onCancel: @props.onCancel
                    onSubmit: @props.onSubmit
                if @state.preview and @props.text
                    PreviewArea
                        realm: @props.realm
                        text: @props.text
