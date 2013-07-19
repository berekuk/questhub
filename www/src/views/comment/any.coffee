define [
    "underscore"
    "views/proto/common"
    "views/comment/like"
    "models/current-user"
    "views/helper/textarea"
    "text!templates/comment.html"
], (_, Common, CommentLike, currentUser, Textarea, html) ->
    class extends Common
        template: _.template(html)
        events:
            "click .delete": "destroy"
            "click .edit": "edit"
            "click .comment-edit-button-cancel": "cancelEdit"
            "click .comment-edit-button-save": "saveEdit"
            "click .comment-reply-link": "reply"
            mouseenter: (e) -> @subview(".likes").showButton()
            mouseleave: (e) -> @subview(".likes").hideButton()

        subviews:
            ".likes": ->
                new CommentLike model: @model

        edit: ->
            return unless @isOwned()
            @$(".comment-content").hide()
            @$(".comment-edit-tools").hide()
            @$(".comment-edit-buttons").show()

            @$(".comment-edit").html("")
            @textarea = new Textarea()
            @textarea.render()
            @$(".comment-edit").append @textarea.$el
            @$(".comment-edit").show()
            @textarea.reveal(@model.get "body")
            @textarea.focus()

            @textarea.on "save", => @saveEdit()
            @textarea.on "cancel", => @cancelEdit()

        cancelEdit: ->
            @textarea.disable() # to avoid accidental saveEdit() because of blur (not relevant anymore)
            @render()
            return


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
                @model.destroy wait: true if result

        serialize: ->
            params = super
            params.my = @isOwned()
            params.currentUser = currentUser.get("login")
            params.realm = @options.realm
            params.quest = @options.quest.toJSON()
            params

        isOwned: ->
            currentUser.get("login") is @model.get("author")

        reply: ->
            @options.quest.trigger "compose-comment",
                reply: @model.get "author"


        features: ["timeago"]
