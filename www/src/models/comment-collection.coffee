define ["backbone", "models/comment", "models/current-user"], (Backbone, Comment, currentUser) ->
    Backbone.Collection.extend
        initialize: (models, args) ->
            @url = ->
                url = "/api/quest/" + args.quest_id + "/comment"
                url

            @quest_id = args.quest_id

        model: Comment
        createTextComment: (body, options) ->
      
            # 'author', 'type' and 'ts' attributes will (hopefully) be ignored by server,
            # but we're going to use them for rendering
            @create
                author: currentUser.get("login")
                body: body
                quest_id: @quest_id
                type: "text"
                ts: Math.floor(new Date().getTime() / 1000)
            , options


