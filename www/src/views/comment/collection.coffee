define [
    "underscore", "jquery", "markdown"
    "views/proto/any-collection"
    "models/current-user"
    "views/user/signin", "views/comment/any"
    "views/helper/textarea"
    "text!templates/comment-collection.html"
], (_, $, markdown, AnyCollection, currentUser, Signin, Comment, Textarea, html) ->
    class extends AnyCollection
        template: _.template(html)
        events:
            "click .submit": "postComment"

        subviews:
            ".signin": ->
                new Signin()
            ".comment-add-sv": ->
                new Textarea
                    realm: @options.realm
                    placeholder: "Comment (Markdown syntax supported)"

        textarea: -> @subview ".comment-add-sv"

        serialize: ->
            currentUser: currentUser.get("login")
            commentBox: @options.commentBox

        generateItem: (model) ->
            new Comment(
                model: model
                realm: @options.realm
                object: @options.object
                commentBox: @options.commentBox
            )

        listSelector: ".comments-list"

        initialize: ->
            @listenTo @options.object, "compose-comment", @composeComment
            @options.commentBox ?= true
            super

        render: ->
            super
            return unless @activated
            if @options.commentBox
                @setupForm()
                @textarea().reveal()
            if @options.reply
                @options.object.trigger "compose-comment", reply: @options.reply
                @options.reply = false

        # set the appropriate "add comment" button style
        validate: (e) =>
            text = @textarea().value()
            @$(".submit").toggleClass "disabled", !text

        setupForm: =>
            @textarea().on "edit", @validate
            @textarea().on "save", @postComment
            @textarea().on "cancel", @cancelComment

        disableForm: =>
            return unless @activated
            @textarea().disable()
            @$(".submit").addClass "disabled"

        resetForm: =>
            return unless @activated
            @textarea().enable()
            @textarea().clear()
            @validate()

        # the difference from resetForm() is that we don't clear textarea's val() to prevent the comment from vanishing
        enableForm: =>
            return unless @activated
            @textarea.enable()
            @validate()

        postComment: =>
            return if @$(".submit").hasClass("disabled")
            @disableForm()
            ga "send", "event", "comment", "add"
            mixpanel.track "add comment"
            @collection.createTextComment @textarea().value(),
                wait: true
                error: @enableForm
                success: @resetForm

        cancelComment: =>
            return if @textarea().value().length > 20
            @textarea().hide()
            @$(".comment-add").hide()

        composeComment: (opt) ->
            opt ?= {}
            el = @$(".comment-add")
            el.show()
            @setupForm()
            @textarea().reveal(if opt.reply then "@#{opt.reply}, " else "")

            newTop = el.offset().top + el.height() + 10 - window.innerHeight
            if newTop > $('body').scrollTop()
                $('html, body').animate {
                    scrollTop: newTop
                }, {
                    complete: => @textarea().focus()
                    duration: 250
                }
            else
                @textarea().focus()
            @validate()

# on success, 'add' will fire and form will be resetted
