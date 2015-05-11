define [
    "underscore", "backbone"
    "react"
    "routers/proto/common"
    "views/helper/react-container"
    "models/current-user"
    "views/quest/page", "models/quest"
    "views/quest/add"
    "models/stencil", "views/stencil/page"
], (_, Backbone, React, Common, ReactContainer, currentUser, QuestPage, QuestModel, QuestAdd, StencilModel, StencilPage) ->
    class extends Common
        routes:
            "quest/add": "questAdd"
            "quest/clone/:id": "questClone"
            "realm/:realm/quest/add": "questAdd"
            "quest/:id": "questPage"
            "realm/:realm/quest/:id": "realmQuestPage"
            "realm/:realm/quest/:id/reply/:reply": "realmQuestPage"
            "realm/:realm/quest/:id/comment/:cid": "anchorQuestPage"
            "stencil/:id": "stencilPage"
            "realm/:realm/stencil/:id": "realmStencilPage"
            "realm/:realm/stencil/:id/quests": "realmStencilPageQuests"
            "realm/:realm/stencil/:id/reply/:reply": "stencilReply"
            "realm/:realm/stencil/:id/comment/:cid": "anchorStencilPage"

        questPage: (id, opts) ->
            opts ?= {}
            model = new QuestModel _id: id
            view = new QuestPage _.extend { model: model }, opts

            model.fetch success: =>
                realUrl = "/realm/" + model.get("realm") + "/quest/" + model.id
                if opts.anchor
                    realUrl += "/comment/#{opts.anchor}"
                Backbone.history.navigate realUrl,
                    replace: true

                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmQuestPage: (realm, id, reply) ->
            @questPage id, { reply: reply }

        anchorQuestPage: (realm, id, cid) ->
            @questPage id, { anchor: cid }

        stencilPage: (id, tab, opts) ->
            opts ?= {}
            model = new StencilModel _id: id
            view = new StencilPage _.extend {
                model: model
                tab: tab
            }, opts

            model.fetch success: =>
                Backbone.history.navigate view.url(),
                    replace: true
                view.activate()
                @appView.updateRealm()

            @appView.setPageView view

        realmStencilPage: (realm, id) ->
            @stencilPage id, 'comments'

        realmStencilPageQuests: (realm, id) ->
            @stencilPage id, 'quests'

        stencilReply: (realm, id, reply) ->
            @stencilPage id, 'comments', { reply: reply }

        anchorStencilPage: (realm, id, cid) ->
            @stencilPage id, 'comments', { anchor: cid }

        questAdd: (realm, cloned_id) ->
            unless currentUser.get("registered")
                @navigate "/",
                    trigger: true
                    replace: true
                return

            options =
                realm: realm
                onTitleChange: (title) => @appView.setWindowTitle title
                onActiveMenuItemChange: (menuItem) => @appView.setActiveMenuItem menuItem

            go = =>
                if realm or cloned_id
                    # we'd have to update url when realm is changed in quest-add dialog otherwise
                    Backbone.history.navigate "/quest/add", replace: true
                view = new ReactContainer QuestAdd, options, null
                view.render()
                @appView.setPageView view

            if cloned_id
                model = new QuestModel _id: cloned_id
                options.cloned_from = model
                model.fetch success: go
            else
                go()

        questClone: (cloned_id) ->
            @questAdd(undefined, cloned_id)
