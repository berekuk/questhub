define ["views/quest/small", "models/quest", "jasmine-jquery"], (QuestSmall, QuestModel) ->
  describe "quest-small", ->
    model = new QuestModel(
      ts: 1360197975
      status: "closed"
      _id: "5112f9577a8f1d370b000002"
      team: ["berekuk", "bessarabov"]
      name: "Fix Google Analytics code on play-perl.org"
      author: "mmcleric"
      tags: ["bug"]
      likes: ["bessarabov", "kappa"]
      realm: "europe"
    )
    describe "render", ->
      view = new QuestSmall(
        model: model
        showStatus: true
      )
      view.render()
      it "small quest is a table row", ->
        expect(view.$el).toBe "tr"

      it "quest status badge", ->
        expect(view.$el.find(".label-false")).toHaveText "complete"

      it "quest tag badge", ->
        expect(view.$el.find(".tag")).toHaveText "bug"


    describe "teammates", ->
      it "show team by default", ->
        view = new QuestSmall(model: model)
        view.render()
        expect(view.$el.html()).toContain "berekuk"
        expect(view.$el.html()).toContain "bessarabov"
        expect(view.$el.html()).not.toContain "with"

      it "show only teammates when user is set", ->
        view = new QuestSmall(
          model: model
          user: "berekuk"
        )
        view.render()
        expect(view.$el.html()).not.toContain "berekuk"
        expect(view.$el.html()).toContain "bessarabov"
        expect(view.$el.html()).toContain "with"





# TODO - test mouseover, will require the mocking of currentUser
