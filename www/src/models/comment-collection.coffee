define [
    "backbone", "models/comment", "models/current-user"
], (Backbone, Comment, currentUser) ->
    class extends Backbone.Collection
        model: Comment
        url: -> "/api/#{@entity}/#{@eid}/comment"

        initialize: (models, args) ->
            @eid = args.eid
            @entity = args.entity

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
