define [
    "backbone"
    "models/quest", "models/stencil"
    "models/comment-collection"
], (Backbone, QuestModel, StencilModel, CommentCollectionModel) ->
    class extends Backbone.Model
        idAttribute: "_id"

        initialize: ->
            super
            @expanded = false
            post = @get("post")
            @postModel = switch post.entity
                when "quest" then new QuestModel post
                when "stencil" then new StencilModel post
                else throw "oops"
            @commentsCollection = new CommentCollectionModel @comments(),
                entity: @postModel.get("entity")
                eid: @postModel.id
            @listenTo @postModel, "destroy", @destroy

        comments: ->
            comments = @get "comments"
            unless @expanded
                if comments.length
                    comments = comments[ comments.length - 1 ]
                else
                    comments = []
            return comments

        needsExpand: -> not @expanded and (@get("comments").length > 1)
        expandCount: -> @get("comments").length - 1

        expand: ->
            @expanded = true
            @commentsCollection.reset @comments()
