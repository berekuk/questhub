define ["views/like"], (Like) ->
    Like.extend
        hidden: true
        my: (currentUser) ->
            @model.get("author") is currentUser.get("login")


