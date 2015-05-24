define [
    "jquery", "underscore"
    "views/proto/common"
    "views/user/signin", "views/helper/textarea"
    "models/current-user"
    "raw!templates/comment/add.html"
], ($, _, Common, Signin, Textarea, currentUser, html) ->
    class extends Common
        template: _.template html

        events:
            "click .submit": "postComment"
            "click .comment-add-aux-controls .dropdown-menu a": "changeType"

        subviews:
            ".signin": ->
                new Signin()
            ".comment-add-textarea-sv": ->
                new Textarea
                    realm: @options.realm
                    placeholder: "Comment"

        textarea: -> @subview ".comment-add-textarea-sv"

        commentType: "text"

        serialize: ->
            types = ["text"]
            types.push "secret" unless @options.object.get("status") == "closed"

            currentUser: currentUser.get("login")
            commentType: @commentType
            types: types

        # set the appropriate "add comment" button style
        validate: (e) =>
            text = @textarea().value()
            @$(".submit").prop "disabled", !text

        initialize: =>
            super
            @textarea().on "edit", @validate
            @textarea().on "save", @postComment
            @textarea().on "cancel", @cancelComment
            @textarea().reveal()

        disableForm: =>
            return unless @activated
            @textarea().disable()
            @$(".submit").prop "disabled", true

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
            return if @$(".submit").prop("disabled")
            @disableForm()
            mixpanel.track "add comment"
            @collection.createComment { body: @textarea().value(), type: @commentType },
                wait: true
                error: @enableForm
                success: =>
                    @resetForm()
                    @commentType = "text"
                    @render()

        cancelComment: =>
            return if @textarea().value().length > 20
            return unless @options.cancelable
            @textarea().hide()
            @$el.hide()

        composeComment: (opt) ->
            opt ?= {}
            @$el.show()
            @textarea().reveal(if opt.reply then "@#{opt.reply}, " else "")

            newTop = @$el.offset().top + @$el.height() + 10 - window.innerHeight
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

        changeType: (e) ->
            @commentType = $(e.target).closest("a").attr "data-comment-type"
            @render()

        render: ->
            super
            @$(".submit").prop "disabled", true unless @textarea().value()
