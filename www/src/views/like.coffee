define ["underscore", "views/proto/push-pull", "raw!templates/like.html"], (_, PushPull, html) ->
    PushPull.extend
        template: _.template(html)
        field: "likes"
        push: ->
            @model.like()

        pull: ->
            @model.unlike()
