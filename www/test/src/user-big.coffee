define [
    "models/another-user",
    "views/user/big"
], (AnotherUserModel, UserBig) ->
    describe "user-big:", ->
        view = undefined
        beforeEach ->
            view = new UserBig
                model: new AnotherUserModel
                    ts: 1360197975
                    login: "somebody"
                    _id: "3333"
                    settings: {}
                    notifications: []
                    pic: "/another-user.png"

            view.render()

        describe "serialize", ->
            it "boolean flags", ->
                expect(view.serialize().following).not.toBe true
                expect(view.serialize().registered).toBeTruthy()
                expect(view.serialize().my).not.toBe true

            it "default tab", ->
                expect(view.serialize().tab).toEqual "quests"
