define ["underscore", "views/proto/common", "views/comment/like", "models/current-user", "text!templates/comment.html"], (_, Common, CommentLike, currentUser, html) ->
    Common.extend
        template: _.template(html)
        events:
            "click .delete": "destroy"
            "click .edit": "edit"
            "blur .comment-edit": "closeEdit"
            mouseenter: (e) ->
                @subview(".likes").showButton()

            mouseleave: (e) ->
                @subview(".likes").hideButton()

        subviews:
            ".likes": ->
                new CommentLike(model: @model)

        edit: ->
            return  unless @isOwned()
            @$(".comment-edit").show()
            @$(".comment-content").hide()
            @$(".comment-edit").focus()
            @$(".comment-edit").autosize()

        closeEdit: ->
            edit = @$(".comment-edit")
            return  if edit.attr("disabled") # already saving
            value = edit.val()
            return  unless value # empty comments are forbidden
            that = this
            edit.attr "disabled", "disabled"
            @model.save
                body: value
            ,
                success: ->
                    that.model.fetch
                        success: ->
                            edit.attr "disabled", false
                            edit.hide()
                            @$(".comment-content").show()
                            that.render()

                        error: (model, xhr, options) ->
                            edit.attr "disabled", false


                error: (model, xhr) ->
                    edit.attr "disabled", false


        destroy: ->
            that = this
            bootbox.confirm "Are you sure you want to delete this comment?", (result) ->
                that.model.destroy wait: true  if result


        features: ["timeago"]
        serialize: ->
            params = @model.toJSON()
            params.my = @isOwned()
            params.realm = @options.realm
            params

        isOwned: ->
            currentUser.get("login") is @model.get("author")


