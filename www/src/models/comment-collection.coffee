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

        createTextComment: (body, options) ->

            # 'author', 'type' and 'ts' attributes will (hopefully) be ignored by server,
            # but we're going to use them for rendering
            @create
                author: currentUser.get("login")
                body: body
                entity: @entity
                eid: @eid
                type: "text"
                ts: Math.floor(new Date().getTime() / 1000)
            , options
