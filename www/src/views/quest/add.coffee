define [
    "underscore", "jquery", "react"
    "views/helper/textarea-react"
    "views/helper/tags-input"
    "views/quest/add/realm-helper"
    "models/shared-models", "models/quest"
    "bootstrap"
], (_, $, React, Textarea, TagsInput, RealmHelper, sharedModels, QuestModel) ->

    {div,section,header,ul,li,select,option,label,small,input,i,button,a} = React.DOM

    MobileRealmSelector = React.createClass
        displayName: "QuestAdd.MobileRealmSelector"

        propTypes:
            realm: React.PropTypes.string
            onSwitchRealm: React.PropTypes.func

        render: ->
            div className: "mobile-inline-block",
                "in"
                select
                    name: "realm"
                    className: "quest-add-realm-select"
                    value: @props.realm
                    onChange: (event) => @props.onSwitchRealm event.target.value
                    option
                        value: "",
                        "Pick a realm:"
                    for r in sharedModels.realms.models
                        do (r) => # creating a variable for each loop iteration
                            option
                                value: r.get('id')
                                key: r.get('id')
                                r.get('name')


    RealmSelector = React.createClass
        displayName: "QuestAdd.RealmSelector"

        propTypes:
            realm: React.PropTypes.string
            onSwitchRealm: React.PropTypes.func

        render: ->
            section className: "quest-add-sidebar sidebar desktop-block #{'quest-add-realm-unpicked' unless @props.realm}",
                div className: "quest-add-realm-list clearfix",
                    header null, "Realm:"
                    ul
                        className: "pills"
                        for r in sharedModels.realms.models
                            do (r) => # creating a variable for each loop iteration
                                li
                                    key: r.get('id')
                                    className: 'active' if r.get('id') == @props.realm
                                    a
                                        href: '#'
                                        onClick: => @props.onSwitchRealm r.get('id')
                                        r.get('name')
                RealmHelper model: sharedModels.realms.findWhere id: @props.realm if @props.realm

    NameInput = React.createClass
        displayName: "QuestAdd.NameInput"

        propTypes:
            value: React.PropTypes.string

        handleChange: (event) ->
            @props.onChange event.target.value

        componentDidUpdate: ->
            @optimizeFont()

        optimizeFont: ->
            el = $(@getDOMNode())
            testerId = "quest-add-test-span"
            tester = $("#" + testerId)
            unless tester.length
                tester = $("<span id=\"#{testerId}\"></span>")
                tester.css "display", "none"
                tester.css "fontFamily", el.css("fontFamily")
                $("body").append tester
            tester.css "fontSize", el.css("fontSize")
            tester.css "lineHeight", el.css("lineHeight")
            tester.text el.val()
            if tester.width() > el.width()
                newFontSize = parseInt(el.css("fontSize")) - 1
                if newFontSize > 14
                    newFontSize += "px"
                    el.css "fontSize", newFontSize
                    el.css "lineHeight", newFontSize

        handleKeyDown: (event) ->
            if event.which is 13
                @props.onSubmit()

        focus: -> @getDOMNode().focus()

        render: ->
            input
                name: "name"
                type: "text"
                className: "input-large"
                placeholder: "What's your next goal?"
                value: @props.value
                onChange: (event) => @props.onChange event.target.value
                onKeyDown: @handleKeyDown

    Form = React.createClass
        displayName: "QuestAdd.Form"

        propTypes:
            realm: React.PropTypes.string
            name: React.PropTypes.string
            tags: React.PropTypes.array
            description: React.PropTypes.string

        focus: ->
            @refs.name.focus()

        render: ->
            div className: "well clearfix quest-add-form",
                div className: "form-row",
                    label null,
                        small className: "muted", "Write a short description of the task here."
                    NameInput
                        ref: "name"
                        value: @props.name
                        onChange: @props.onNameChange
                        onSubmit: @props.onSubmit

                div className: "form-row",
                    label null,
                        small className: "muted", "Description:"
                    Textarea
                        realm: @props.realm # TODO
                        text: @props.description
                        placeholder: "Quest details are optional. You can always add them later."
                        onTextChange: @props.onDescriptionChange
                        onSubmit: @props.onSubmit

                div className: "form-row",
                    label null,
                        small className: "muted", 'Tags are optional. Enter them comma-separated here (for example: "bug,dancer"):'
                    TagsInput
                        tags: @props.tags
                        onChange: @props.onTagsChange
                        onValid: @props.onFormIsValid
                        onSubmit: @props.onSubmit

    Buttons = React.createClass
        displayName: "QuestAdd.Buttons"

        propTypes:
            submittable: React.PropTypes.bool
            submitted: React.PropTypes.bool

        render: ->
            div className: "pull-right",
                i className: "icon-spinner icon-spin" if @props.submitted
                button
                    className: "btn btn-large btn-default"
                    onClick: @props.onClose
                    "Cancel"
                " "
                button
                    className: "btn btn-large btn-primary #{'disabled' unless @props.submittable}"
                    dataPlacement: "top"
                    dataTitle: "pick a realm first"
                    dataAnimation: "false"
                    dataTrigger: "hover"
                    onClick: @props.onSubmit
                    "Start quest"

    React.createClass
        displayName: "QuestAdd"

        propTypes:
            realm: React.PropTypes.string
            cloned_from: React.PropTypes.any # Backbone model

        getInitialState: ->
            if @props.cloned_from
                state =
                    name: @props.cloned_from.get('name')
                    realm: @props.cloned_from.get('realm')
                    description: @props.cloned_from.get("description")
                    tags: @props.cloned_from.get("tags")
            else
                state =
                    name: ""
                    realm: @props.realm # copying over, that's ok
                    description: ""
                    tags: []

            unless state.realm
                # TODO - untested!
                userRealms = sharedModels.currentUser.get("realms")
                state.realm = userRealms[0] if userRealms and userRealms.length is 1

            state.submitted = false
            state.valid = true
            return state

        submittable: -> Boolean not @state.submitted and @state.name and @state.realm and @state.valid

        submit: ->
            return unless @submittable()

            @model = new QuestModel()

            modelProps =
                name: @state.name
                realm: @state.realm
                description: @state.description # to be filled
                tags: @state.tags

            if @props.cloned_from
                modelProps.cloned_from = @props.cloned_from.id

            @model.set modelProps

            @model.save {},
                success: =>
                    Backbone.trigger "pp:quest-add", @model
                    @close()

            ga "send", "event", "quest", "add"
            mixpanel.track "add quest"

            # the component will be destroyed now, but whatever
            @setState submitted: true

        close: ->
            Backbone.history.navigate "/", trigger: true, replace: true

        handleSwitchRealm: (realm) ->
            @setState realm: realm
            @refs.form.focus()

        componentDidMount: ->
            @props.onTitleChange? "New quest"
            @props.onActiveMenuItemChange? "new-quest"

        render: ->
            div className: "quest-add",
                RealmSelector
                    realm: @state.realm
                    onSwitchRealm: @handleSwitchRealm
                section className: "quest-add-mainarea mainarea",
                    header null,
                        "Go on a quest"
                        MobileRealmSelector
                            realm: @state.realm
                            onSwitchRealm: @handleSwitchRealm
                    Form
                        ref: "form"
                        realm: @state.realm
                        name: @state.name
                        tags: @state.tags
                        description: @state.description
                        onTagsChange: (tags) => @setState tags: tags
                        onNameChange: (name) => @setState name: name
                        onDescriptionChange: (description) => @setState description: description
                        onFormIsValid: (valid) => @setState valid: valid
                        onSubmit: @submit
                    Buttons
                        submitted: @state.submitted
                        submittable: @submittable()
                        onClose: @close
                        onSubmit: @submit
