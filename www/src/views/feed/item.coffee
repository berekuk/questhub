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

        events: ->
            "click .feed-item-expand-comments": "expandComments"

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
