define ["models/quest"], (QuestModel) ->
    describe "model/quest:", ->
        describe "serialize", ->
            model = undefined
            modelParams =
                ts: 1360197975
                status: "open"
                _id: "5112f9577a8f1d370b000002"
                team: ["badger"]
                name: "Badger Badger"
                author: "jonti"
                tags: ["feature"]
                likes: ["mushroom", "snake"]
                base_points: 1
                points: 1

            beforeEach ->
                model = new QuestModel(modelParams)

            it "all properties", ->
                expect(model.serialize()).toEqual _.extend(modelParams,
                    ext_status: "open"
                    my: false
                )

            it "ext_status of open quest", ->
                expect(model.serialize().ext_status).toEqual "open"

            it "ext_status of unclaimed quest", ->
                model.set "team", []
                expect(model.serialize().ext_status).toEqual "unclaimed"
