define [
    "underscore", "jquery"
    "views/proto/common"
    "views/comment/like"
    "models/current-user"
    "views/helper/textarea"
    "text!templates/comment.html"
], (_, $, Common, CommentLike, currentUser, Textarea, html) ->
    class extends Common
        className: "comment-outer"

        template: _.template(html)
        events:
            "click .delete": "destroy"
            "click .edit": "edit"
            "click .comment-edit-button-cancel": "cancelEdit"
            "click .comment-edit-button-save": "saveEdit"
            "click .comment-reply-link": "reply"
            "mouseenter": "mouseenter"
            "mouseleave": "mouseleave"

        mouseenter: -> @subview(".likes").showButton()
        mouseleave: -> @subview(".likes").hideButton()

        subviews:
            ".likes": ->
                new CommentLike model: @model

        edit: ->
            return unless @isOwned()
            @$(".comment-content").hide()
            @$(".comment-edit-tools").hide()
            @$(".comment-edit-buttons").show()

            @$(".comment-edit").html("")
            @textarea = new Textarea realm: @options.realm
            @textarea.render()
            @$(".comment-edit").append @textarea.$el
            @$(".comment-edit").show()
            @textarea.reveal(@model.get "body")
            @textarea.focus()

            mixpanel.track "start edit", entity: "comment"
            @textarea.on "save", => @saveEdit()
            @textarea.on "cancel", => @cancelEdit()

        cancelEdit: -> @render()

        saveEdit: ->
            return if @textarea.disabled()
            value = @textarea.value()
            return unless value # empty comments are forbidden

            @textarea.disable()
            deferred = @model.save body: value
            deferred.success =>
                @model.fetch
                    success: => @render() # rendering fixes everything, cleans up our Textarea, re-draws content, etc.
                    error: (model, xhr, options) => @textarea.enable()

            deferred.error (model, xhr) =>
                @textarea.enable()


        destroy: ->
            bootbox.confirm "Are you sure you want to delete this comment?", (result) =>
                mixpanel.track "delete", entity: "comment"
                @model.destroy wait: true if result

        serialize: ->
            params = super
            params.my = @isOwned()
            params.currentUser = currentUser.get("login")
            params.realm = @options.realm
            params.object = @options.object.toJSON()
            params

        isOwned: ->
            currentUser.get("login") is @model.get("author")

        reply: ->
            @options.object.trigger "compose-comment",
                reply: @model.get "author"

        render: ->
            # to clean up cachedText state and avoid memory leaks (I really should turn it into more manageable subview)
            @textarea?.remove()
            delete @textarea
            super

        highlight: ->
            # don't flash on re-render
            if @highlighted
                @$(".comment").removeClass "flash"
                return
            @highlighted = true

            $('html, body').animate {
                scrollTop: @$el.offset().top - $(".navbar").height() - 5
            }, {
                complete: => @$(".comment").addClass "flash"
                duration: 0
            }

        features: ["timeago"]

        detachFromDOM: ->
            super
            @textarea?.detachFromDOM()

        reattachToDOM: ->
            super
            @textarea?.reattachToDOM()
