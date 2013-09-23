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
            @tailLength = @_commentsTailLength()
            post = @get("post")
            @postModel = switch post.entity
                when "quest" then new QuestModel post
                when "stencil" then new StencilModel post
                else throw "oops"
            @commentsCollection = new CommentCollectionModel @comments(),
                entity: @postModel.get("entity")
                eid: @postModel.id
            @listenTo @postModel, "destroy", @destroy

        _commentsTailLength: ->
            comments = @get "comments"
            unless comments.length
                return 0 # doesn't matter, we're checking for comments.length in all relevant places
            if comments.length < 2
                return 1
            last = comments[ comments.length - 1 ]
            prev = comments[ comments.length - 2 ]
            if last.body and prev.body
                return 1
            return 2

        comments: ->
            comments = @get "comments"
            unless @expanded
                if comments.length
                    comments = comments.slice(comments.length - @tailLength)
                else
                    comments = []
            return comments

        needsExpand: -> not @expanded and (@get("comments").length > @tailLength)
        expandCount: -> @get("comments").length - @tailLength

        expand: ->
            return if @expanded
            @expanded = true
            comments = @get("comments")
            for comment in comments.slice(0, comments.length - @tailLength).reverse()
                @commentsCollection.add(comment, prepend: true)

            ## alternative version; it would be nice to refetch comments, but it's broken:
            ## it appends comments to the last, visible comment, which turns out on top when it should be on bottom
            ## see also: views/feed/item expandComments()
            #
            #deferred = @commentsCollection.fetch()
            #deferred.success => @expanded = true
            #return deferred
