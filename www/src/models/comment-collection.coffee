define [
    "backbone", "models/comment", "models/current-user"
], (Backbone, Comment, currentUser) ->
    class extends Backbone.Collection
        model: Comment
        url: -> "/api/#{@entity}/#{@eid}/comment"

        initialize: (models, args) ->
            @eid = args.eid
            @entity = args.entity
            cmp = (a, b) ->
                return 1 if a > b
                return -1 if a < b
                return 0
            @comparator = (m1, m2) -> cmp m1.get("ts"), m2.get("ts")

        createComment: (comment, options) ->

            # 'author' and 'ts' attributes will (hopefully) be ignored by server,
            # but we're going to use them for rendering
            comment = _.extend comment,
                author: currentUser.get("login")
                entity: @entity
                eid: @eid
                ts: Math.floor(new Date().getTime() / 1000)
                secret_id: "fake"
            @create comment, options
