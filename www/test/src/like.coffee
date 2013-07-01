define ["models/current-user", "models/quest", "views/quest/like"], (currentUser, QuestModel, Like) ->
    describe "like:", ->
        beforeEach ->
            spyOn $, "ajax"

        proto =
            ts: 1360197975
            status: "open"
            _id: "5112f9577a8f1d370b000002"
            team: ["bar"]
            name: "q1"
            author: "bar"

        describe "quest without likes", ->
            model = new QuestModel(_.extend(proto, {}))
            view = new Like(model: model)
            view.render()

            it "contains likes badge", ->
                expect(view.$el).toContain ".like-button"

            it "badge value is 0", ->
                expect(view.$el.find(".like-button")).toHaveText "0"

            it "is clickable", ->
                expect(view.$el).toContain "a"


        describe "quest with likes", ->
            model = new QuestModel(_.extend(proto,
                likes: ["baz", "baz2"]
            ))
            view = new Like(model: model)
            view.render()

            it "contains likes badge", ->
                expect(view.$el).toContain ".like-button"
                expect(view.$(".like-button")).toHaveText "2"

            it "is clickable", ->
                expect(view.$el).toContain "a"


        describe "current user's quest", ->
            model = new QuestModel(_.extend(proto,
                likes: ["baz", "baz2"]
                team: ["jasmine"]
                user: "jasmine"
            ))
            view = new Like(model: model)
            view.render()

            it "contains likes badge", ->
                expect(view.$el).toContain ".like-button"

            it "not clickable", ->
                expect(view.$el).not.toContain "a"
