define [
    "models/another-user", "models/current-user"
    "views/dashboard"
], (AnotherUserModel, currentUser, Dashboard) ->
    describe "dashboard:", ->
        view = undefined
        beforeEach ->
            view = new Dashboard(model: currentUser)
            view.activate()
            view.render()

        describe "initial tab", ->
            it "tab property", ->
                expect(view.tab).toEqual "quests"

            it "highlighted tab link", ->
                expect(view.$el.find(".user-big-tabs ._active").attr("data-tab")).toEqual "quests"

        describe "quests tab change", ->
            beforeEach ->
                sinon.spy Backbone, "trigger"
                view.$el.find(".user-big-tabs [data-tab=activity]").click()
            afterEach ->
                Backbone.trigger.restore()

            it "changes view.tab", ->
                expect(view.tab).toBe "activity"

            it "updates url", ->
                expect(Backbone.trigger.called).toBe true
                expect(Backbone.trigger.getCall(0).args[0]).toEqual "pp:navigate"
                expect(Backbone.trigger.getCall(0).args[1]).toEqual "/player/jasmine/activity"

            it "highlighted tab link", ->
                expect(view.$el.find(".user-big-tabs ._active").attr("data-tab")).toEqual "activity"


    describe "another user's dashboard:", ->
        proto =
            ts: 1360197975
            login: "somebody"
            _id: "3333"
            settings: {}
            notifications: []
            pic: "/another-user.png"

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
