define [
    "underscore"
    "views/proto/common"
    "views/comment/collection", "models/comment-collection"
    "text!templates/stencil/page/comments.html"
], (_, Common, CommentCollection, CommentCollectionModel, html) ->
    class extends Common
        template: _.template html
        subviews:
            ".stencil-page-comments-sv": ->
                commentsModel = new CommentCollectionModel([],
                    entity: 'stencil'
                    eid: @model.id
                )
                commentsModel.fetch()
                new CommentCollection(
                    collection: commentsModel
                    realm: @model.get("realm")
                    object: @model
                    reply: @options.reply
                )
