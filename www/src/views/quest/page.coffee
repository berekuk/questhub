define [
    "underscore"
    "views/proto/common"
    "views/quest/completed"
    "views/realm/submenu", "views/quest/checkins", "views/quest/big", "views/comment/collection"
    "models/comment-collection", "models/current-user", "models/shared-models"
    "text!templates/quest/page.html"
    "jquery.typeahead"
], (_, Common, QuestCompleted, RealmSubmenu, QuestCheckins, QuestBig, CommentCollection, CommentCollectionModel, currentUser, sharedModels, html) ->
    class extends Common
        activated: false
        template: _.template(html)
        events:
            "click .quest-page-action .complete": "close"
            "click .quest-page-action .abandon": "abandon"
            "click .quest-page-action .leave": "leave"
            "click .quest-page-action .resurrect": "resurrect"
            "click .quest-page-action .reopen": "reopen"
            "click .invite": "inviteDialog"
            "click .uninvite": "uninvite"
            "click .join": "joinAction"
            "click .like": -> @model.like()
            "click .unlike": -> @model.unlike()
            "click .watch": -> @model.act "watch"
            "click .unwatch": -> @model.act "unwatch"
            "keyup #inputInvitee": "inviteAction"

        realm: -> @model.get "realm"
        pageTitle: -> @model.get "name"

        realmModel: -> sharedModels.realms.findWhere id: @realm()

        subviews:
            ".realm-submenu-sv": ->
                new RealmSubmenu model: @realmModel()

            ".quest-big": ->
                new QuestBig(model: @model)

            ".quest-checkins-sv": ->
                new QuestCheckins(model: @model)

            ".comments": ->
                commentsModel = new CommentCollectionModel([],
                    entity: 'quest'
                    eid: @model.id
                )
                commentsModel.fetch()
                new CommentCollection(
                    collection: commentsModel
                    realm: @realm()
                    object: @model
                    reply: @options.reply
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

        uninvite: (e) ->
            @model.uninvite $(e.target).parent().attr("data-login")

        close: ->
            @model.close()
            modal = new QuestCompleted(model: @model)
            modal.start()

        reopen: -> @model.reopen()

        abandon: -> @model.abandon()
        resurrect: -> @model.resurrect()
        leave: -> @model.leave()
        join: -> @model.join()

        serialize: ->
            params = super
            params.currentUser = currentUser.get("login")
            params.invited = _.contains(params.invitee or [], params.currentUser)
            params.meGusta = _.contains(params.likes or [], params.currentUser)

            params.realmData = @realmModel().toJSON()
            params

        initialize: ->
            super
            @listenTo @model, "change", =>
                @render()
                @trigger "change:page-title"

            @listenTo @model, "act", ->
                @subview(".comments").collection.fetch()

        features: ["tooltip"]
