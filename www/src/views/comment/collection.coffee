define [
    "underscore", "jquery"
    "views/proto/any-collection"
    "models/current-user"
    "views/comment/any"
    "views/comment/add"
    "raw!templates/comment-collection.html"
], (_, $, AnyCollection, currentUser, Comment, CommentAdd, html) ->
    class extends AnyCollection
        template: _.template html

        subviews:
            ".comment-add-sv": ->
                new CommentAdd
                    realm: @options.realm
                    collection: @collection
                    cancelable: !@options.commentBox
                    object: @options.object
        lazySubviews: [".comment-add-sv"]

        serialize: ->
            currentUser: currentUser.get("login")

        generateItem: (model) ->
            new Comment
                model: model
                realm: @options.realm
                object: @options.object

        listSelector: ".comments-list"

        initialize: (options) ->
            @listenTo options.object, "compose-comment", @composeComment
            options.commentBox ?= true
            super

        render: ->
            super
            return unless @activated
            if @options.commentBox
                @initLazySubview(".comment-add-sv")
            if @options.reply
                @options.object.trigger "compose-comment", reply: @options.reply
                @options.reply = false
            if @options.anchor
                comment = _.find @itemSubviews, (sv) => sv.model.id == @options.anchor
                comment?.highlight()

        composeComment: (opt) ->
            @initLazySubview(".comment-add-sv").composeComment(opt)
