define [
    "underscore"
    "views/proto/common"
    "views/quest/feed", "models/quest"
    "views/stencil/feed", "models/stencil"
    "views/comment/collection", "models/comment-collection"
    "text!templates/feed/item.html"
], (_, Common, Quest, QuestModel, Stencil, StencilModel, CommentCollection, CommentCollectionModel, html) ->
    class extends Common
        template: _.template html

        initialize: ->
            post = @model.get "post"
            @postModel = switch post.entity
                when "quest" then new QuestModel post
                when "stencil" then new StencilModel post
                else throw "oops"
            super

        events: ->
            "click .feed-item-expand-comments": "expandComments"

        subviews:
            ".quest-sv": ->
                return switch @postModel.get("entity")
                    when "quest" then new Quest model: @postModel
                    when "stencil" then new Stencil model: @postModel
                    else throw "oops"
            ".comments-sv": ->
                # note: already fetched
                commentsModel = new CommentCollectionModel [],
                    entity: @postModel.get("entity")
                    eid: @postModel.id

                view = new CommentCollection
                    collection: commentsModel
                    realm: @postModel.get("realm")
                    object: @postModel
                    commentBox: false

                comments = @model.get "comments"
                unless @expanded
                    if comments.length
                        comments = comments[ comments.length - 1 ]
                    else
                        comments = []
                commentsModel.reset comments

                view

        expandComments: ->
            @expanded = true
            @rebuildSubview ".comments-sv" # FIXME - preserve textarea if necessary
            @render()


        serialize: ->
            expand: not @expanded and (@model.get("comments").length > 1)
            expandCount: @model.get("comments").length - 1
