define ["underscore", "markdown", "views/proto/any-collection", "models/current-user", "views/user/signin", "views/comment/any", "text!templates/comment-collection.html"], (_, markdown, AnyCollection, currentUser, Signin, Comment, html) ->
    class extends AnyCollection
        template: _.template(html)
        events:
            "click .submit": "postComment"
            "keyup [name=comment]": "validate"

        subviews:
            ".signin": ->
                new Signin()

        celem: ->
            @$ "[name=comment]"

        serialize: ->
            currentUser: currentUser.get("login")

        generateItem: (model) ->
            new Comment(
                model: model
                realm: @options.realm
            )

        listSelector: ".comments-list"
        afterInitialize: ->
            @listenTo @collection, "add", @resetForm
            super

        afterRender: ->
            super
            @$("[name=comment]").autosize()


        # set the appropriate "add comment" button style
        validate: (e) ->
            text = @celem().val()
            if text
                @$(".submit").removeClass "disabled"
                @$(".comment-preview").show()
                @$(".comment-preview ._content").html markdown(text, @options.realm)
            else
                @$(".submit").addClass "disabled"
                @$(".comment-preview").hide()

        disableForm: ->
            @celem().attr disabled: "disabled"
            @$(".submit").addClass "disabled"

        resetForm: ->
            @celem().removeAttr "disabled"
            @celem().val ""
            @validate()

        enableForm: ->

            # the difference from resetForm() is that we don't clear textarea's val() to prevent the comment from vanishing
            @celem().removeAttr "disabled"
            @validate()

        postComment: ->
            return  if @$(".submit").hasClass("disabled")
            @disableForm()
            ga "send", "event", "comment", "add"
            mixpanel.track "add comment"
            @collection.createTextComment @celem().val(),
                wait: true
                error: @enableForm




# on success, 'add' will fire and form will be resetted
