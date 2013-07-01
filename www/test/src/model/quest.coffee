define ["models/quest", "jasmine-jquery"], (QuestModel) ->
  describe "model/quest", ->
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

      beforeEach ->
        model = new QuestModel(modelParams)

      it "all properties", ->
        expect(model.serialize()).toEqual _.extend(modelParams,
          reward: 3
          ext_status: "open"
          my: false
        )

      it "ext_status of open quest", ->
        expect(model.serialize().ext_status).toEqual "open"

      it "ext_status of unclaimed quest", ->
        model.set "team", []
        expect(model.serialize().ext_status).toEqual "unclaimed"

      it "reward when likes are empty", ->
        model.set "likes", []
        expect(model.serialize().reward).toEqual 1

      it "reward when there are no likes", ->
        model.unset "likes"
        expect(model.serialize().reward).toEqual 1




