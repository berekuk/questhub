define [
    "models/another-user",
    "views/user/big"
], (AnotherUserModel, UserBig) ->
    describe "user-big:", ->
        view = undefined

        emptyModel = ->
            new AnotherUserModel
                ts: 1360197975
                login: "somebody"
                _id: "3333"
                settings: {}
                notifications: []
                pic: "/another-user.png"

        scoredModel = ->
            new AnotherUserModel
                ts: 1360197975
                login: "somebody"
                _id: "3333"
                settings: {}
                notifications: []
                pic: "/another-user.png"
                rp:
                    europe: 5
                    asia: 7
                rph: [
                    { europe: 1, asia: 3 }
                    { europe: 2, asia: 3 }
                    { europe: 2, asia: 5 }
                ]

        prepareView = (model) ->
            view = new UserBig model: model
            view.render()

        describe "serialize", ->
            beforeEach -> prepareView emptyModel()

            it "boolean flags", ->
                expect(view.serialize().following).not.toBe true
                expect(view.serialize().registered).toBeTruthy()
                expect(view.serialize().my).not.toBe true

            it "default tab", ->
                expect(view.serialize().tab).toEqual "quests"

        describe "when rendering empty user", ->
            beforeEach -> prepareView emptyModel()
            it "points total is zero", ->
                expect(view.$(".user-big-points .reward-points").html()).toEqual '0'

        describe "when rendering scored user", ->
            beforeEach -> prepareView scoredModel()
            it "points total is the sum of all realms", ->
                expect(view.$(".user-big-points .reward-points").html()).toEqual '12'
