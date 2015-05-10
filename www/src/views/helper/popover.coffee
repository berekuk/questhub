define [
    "react"
], (React) ->
    {div, h3} = React.DOM

    classSet = (classNames) ->
        Object.keys(classNames).filter((className) ->
            classNames[className]
        ).join(' ')

    React.createClass
        propTypes:
            placement: React.PropTypes.oneOf ['top','right', 'bottom', 'left']
            positionLeft: React.PropTypes.number
            positionTop: React.PropTypes.number
            arrowOffsetLeft: React.PropTypes.number
            arrowOffsetTop: React.PropTypes.number
            title: React.PropTypes.any

        getDefaultProps: ->
            placement: 'right'

        render: ->
            classes =
                popover: true
                in: @props.positionLeft != null or @props.positionTop != null
            classes[@props.placement] = true

            style =
                left: @props.positionLeft
                top: @props.positionTop
                display: 'block'

            arrowStyle =
                left: @props.arrowOffsetLeft
                top: @props.arrowOffsetTop

            div
                className: classSet classes
                style: style
                div className: "arrow", style: arrowStyle
                @renderTitle() if @props.title
                div className: "popover-content",
                    @props.children

        renderTitle: ->
            h3
                className: "popover-title"
                @props.title
