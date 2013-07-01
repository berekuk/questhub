define [
    "models/another-user", "models/current-user"
    "views/dashboard"
], (AnotherUserModel, currentUser, Dashboard) ->
    describe "dashboard:", ->
        view = new Dashboard(model: currentUser)

        it "default tab", ->
            expect(view.tab).toBe "open"

    describe "another user's dashboard:", ->
        proto =
            ts: 1360197975
            login: "somebody"
            _id: "3333"
            settings: {}
            notifications: []

        model = new AnotherUserModel(_.extend(proto, {}))
        view = new Dashboard(model: model)

        it "my() is false", ->
            expect(view.my()).not.toBe true
        it "active menu item", ->
            expect(view.activeMenuItem()).toBe "none"

    describe "current user's dashboard:", ->
        view = new Dashboard(model: currentUser)

        it "my() is true", ->
            expect(view.my()).toBe true
        it "active menu item", ->
            expect(view.activeMenuItem()).toBe "my-quests"
