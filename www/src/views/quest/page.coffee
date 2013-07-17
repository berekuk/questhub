define [
    "underscore"
    "views/proto/common"
    "views/quest/completed"
    "views/quest/big", "views/comment/collection"
    "models/comment-collection", "models/current-user"
    "text!templates/quest/page.html"
    "jquery.typeahead"
], (_, Common, QuestCompleted, QuestBig, CommentCollection, CommentCollectionModel, currentUser, html) ->
    class extends Common
        activated: false
        template: _.template(html)
        events:
            "click .quest-action .complete": "close"
            "click .quest-action .abandon": "abandon"
            "click .quest-action .leave": "leave"
            "click .quest-action .resurrect": "resurrect"
            "click .quest-action .reopen": "reopen"
            "click .invite": "inviteDialog"
            "click .uninvite": "uninviteAction"
            "click .join": "joinAction"
            "click .like": -> @model.like()
            "click .unlike": -> @model.unlike()
            "click .watch": -> @model.act "watch"
            "click .unwatch": -> @model.act "unwatch"
            "keyup #inputInvitee": "inviteAction"

        realm: -> @model.get "realm"

        subviews:
            ".quest-big": ->
                new QuestBig(model: @model)

            ".comments": ->
                commentsModel = new CommentCollectionModel([],
                    quest_id: @model.id
                )
                commentsModel.fetch()
                new CommentCollection(
                    collection: commentsModel
                    realm: @realm()
                    quest: @model
                )

        inviteDialog: ->
            @$(".invite.button").hide()
            @$(".invite-dialog").show 0, =>
                @$(".invite-dialog input").typeahead
                    name: "users"
                    remote: "/api/user/%QUERY/autocomplete"
                @$(".invite-dialog input").focus()


        inviteAction: (e) ->

            # escape
            if e.keyCode is 27
                @$(".invite-dialog input").typeahead "destroy"
                @$(".invite-dialog").hide()
                @$(".invite-dialog input").val ""
                @$(".invite.button").show()
                return

            # enter
            @model.invite @$("#inputInvitee").val()  if e.keyCode is 13
            return

        uninviteAction: (e) ->
            @model.uninvite $(e.target).parent().attr("data-login")

        joinAction: ->
            @model.join()

        close: ->
            @model.close()
            modal = new QuestCompleted(model: @model)
            modal.start()

        abandon: -> @model.abandon()
        leave: -> @model.leave()
        resurrect: -> @model.resurrect()
        reopen: -> @model.reopen()

        serialize: ->
            params = super
            params.currentUser = currentUser.get("login")
            params.invited = _.contains(params.invitee or [], params.currentUser)
            params.meGusta = _.contains(params.likes or [], params.currentUser)
            params

        afterInitialize: ->
            @listenTo @model, "change", @render
            @listenTo @model, "act", ->
                @subview(".comments").collection.fetch()

        features: ["tooltip"]
