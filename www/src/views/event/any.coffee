define [
    "backbone", "underscore", "jquery"
    "views/proto/common"
    "views/quest/like", "views/comment/like"
    "models/quest", "models/comment"
    "text!templates/event.html"
], (Backbone, _, $, Common, QuestLike, CommentLike, QuestModel, CommentModel, html) ->
    class extends Common
        template: _.template(html)
        features: ["timeago"]

        # TODO - add 'close-quest' here too, after I fix the model sync issue
        # (if you like quest from one event, it doesn't affect the likes on the same quest in other event, since the model is not shared;
        # and then if you like another instance of this quest, you get error 500, because double liking is considered fatal (which is probably a mistake))
        likeable: ["add-quest", "add-comment"]
        events: ->
            if _.contains(@likeable, @model.name())
                mouseenter: (e) ->
                    @subview(".likes").showButton()

                mouseleave: (e) ->
                    @subview(".likes").hideButton()
            else
                {}

        subviews: ->
            if @model.name() is "add-quest"
                ".likes": ->
                    questModel = new QuestModel(@model.get("quest"))
                    new QuestLike(
                        model: questModel
                        hidden: true
                    )
            else if @model.name() is "add-comment"
                ".likes": ->
                    commentModel = new CommentModel(@model.get("comment"))
                    new CommentLike(model: commentModel)
            else
                {}

        serialize: ->
            params = super
            params.showRealm = @options.showRealm
            params
