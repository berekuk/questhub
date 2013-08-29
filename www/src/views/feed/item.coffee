define [
    "underscore"
    "views/proto/common"
    "views/quest/feed"
    "views/stencil/feed"
    "views/comment/collection", "models/comment-collection"
    "text!templates/feed/item.html"
], (_, Common, Quest, Stencil, CommentCollection, CommentCollectionModel, html) ->
    class extends Common
        template: _.template html

        events: ->
            "click .feed-item-expand-comments": "expandComments"

        subviews:
            ".quest-sv": ->
                postModel = @model.postModel
                return switch postModel.get("entity")
                    when "quest" then new Quest model: postModel
                    when "stencil" then new Stencil model: postModel
                    else throw "oops"
            ".comments-sv": ->
                view = new CommentCollection
                    collection: @model.commentsCollection
                    realm: @model.postModel.get("realm")
                    object: @model.postModel
                    commentBox: false
                view.activate()
                return view

        expandComments: ->
            @model.expand()
            @$(".feed-item-expand-comments-panel").hide()

        serialize: ->
            expand: @model.needsExpand()
            expandCount: @model.expandCount()
