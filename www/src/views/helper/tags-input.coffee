define [
    "jquery", "react"
    "models/quest"
    "bootstrap"
], ($, React, QuestModel) ->

    {input,span} = React.DOM

    React.createClass
        displayName: "TagsInput"

        propTypes:
            tags: React.PropTypes.array.isRequired
            onChange: React.PropTypes.func.isRequired
            onValid: React.PropTypes.func.isRequired
            onSubmit: React.PropTypes.func

        getInitialState: ->
            # Note: we're intentionally copying tags over to the tagline.
            # Dirty plain-text line is the internal variable, while parsed array of tags is exposed via onChange().
            # Boolean status of plain-text line is exposed via onValid(true/false) callback..
            tagline: @props.tags.join(', ')
            valid: true

        handleChange: (event) ->
            tagline = event.target.value
            valid = QuestModel::validateTagline(tagline)
            @setState
                tagline: tagline
                valid: valid

            if valid
                @props.onValid true
                @props.onChange QuestModel::tagline2tags tagline
            else
                @props.onValid false

        componentDidUpdate: ->
            el = $(@getDOMNode())
            el.find("input").tooltip(if @state.valid then "hide" else "show")

        handleKeyDown: (event) ->
            if event.which is 13
                @props.onSubmit?()

        render: ->
            span className: "tags-edit control-group #{"error" unless @state.valid}", # .control-group is necessary for 'error' class to function
                input
                    type: "text"
                    value: @state.tagline
                    'data-placement': "top"
                    'data-title': "tags must be alphanumerical"
                    'data-animation': "false"
                    'data-trigger': "manual"
                    onChange: @handleChange
                    onKeyDown: @handleKeyDown
