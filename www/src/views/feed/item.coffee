define [
    "underscore"
    "views/proto/common"
    "views/quest/feed"
    "views/stencil/feed"
    "views/comment/collection", "models/comment-collection"
    "views/progress"
    "text!templates/feed/item.html"
], (_, Common, Quest, Stencil, CommentCollection, CommentCollectionModel, Progress, html) ->
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

                # activate comments view (since comments are already fetched and "reset" or "sync" won't fire)
                # but don't render
                view.activated = true
                view.initSubviews()

                return view
            ".expand-progress-sv": -> new Progress()

        expandComments: ->
            @model.expand()
            @$(".feed-item-expand-comments-panel").hide()

            ## see also: comment in models/feed/item expand()
            #
            #progress = @subview(".expand-progress-sv")
            #progress.on()
            #deferred = @model.expand()
            #deferred.always => progress.off()
            #deferred.success => @$(".feed-item-expand-comments-panel").hide()

        serialize: ->
            expand: @model.needsExpand()
            expandCount: @model.expandCount()
