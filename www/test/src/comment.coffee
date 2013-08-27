define [
    "models/comment", "models/quest"
    "views/comment/any"
], (CommentModel, QuestModel, CommentText) ->
    describe "comments render", ->
        model = new CommentModel(
            body: "aaa"
            ts: 1363395653
            body_html: "aaa\n"
            entity: "quest"
            _id: "1234"
            eid: "5143c351dd3d73910c00000e"
            author: "ooo"
            type: "text"
        )
        questModel = new QuestModel(
                ts: 1360197975
                status: "open"
                _id: "5112f9577a8f1d370b000002"
                team: ["badger"]
                name: "Badger Badger"
                author: "jonti"
                tags: ["feature"]
                base_points: 1
                points: 1
        )
        view = new CommentText(
            model: model
            object: questModel
        )
        view.render()
        it "comment body", ->
            expect(view.$el.html()).toContain "aaa"

        it "comment author", ->
            expect(view.$el.html()).toContain "ooo"
