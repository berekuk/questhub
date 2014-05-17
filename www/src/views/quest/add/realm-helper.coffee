define [
    "underscore"
    "react"
    "views/proto/common"
], (_, React, Common) ->
    {div,img,p,span,br,a} = React.DOM
    React.createClass
        render: ->
            model = @props.model
            if model and model.get('pic')
                content = div null,
                    img src: model.get('pic')
                    if model.get('stat').stencils
                        p null,
                            span className: "label label-important",
                                "New!"
                            br null
                            a href: "/realm/#{ model.get('id') }/stencils",
                                "Choose a quest from #{ model.get('stat').stencils } stencils."

            div className: "quest-add-realm-helper", content
