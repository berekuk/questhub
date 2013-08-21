define [
    "underscore"
    "views/proto/common"
    "views/quest/feed", "models/quest"
    "views/comment/collection", "models/comment-collection"
    "text!templates/feed/item.html"
], (_, Common, Quest, QuestModel, CommentCollection, CommentCollectionModel, html) ->
    class extends Common
        template: _.template html

        initialize: ->
            @questModel = new QuestModel @model.get("quest")
            super

        subviews:
            ".quest-sv": ->
                new Quest
                    model: @questModel
            ".comments-sv": ->
                # note: already fetched
                commentsModel = new CommentCollectionModel [],
                    entity: 'quest'
                    eid: @questModel.id

                view = new CommentCollection
                    collection: commentsModel
                    realm: @questModel.get("realm")
                    object: @questModel
                    commentBox: false

                commentsModel.reset @model.get "comments"
                view
