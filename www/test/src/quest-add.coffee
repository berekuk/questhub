define ["jquery", "views/quest/add", "models/quest-collection", "jasmine-jquery"], ($, QuestAdd, QuestCollection) ->
  describe "quest-add:", ->
    view = undefined
    beforeEach ->
      spyOn $, "ajax"
      view.remove()  if view
      el = $("<div style=\"display:none\"></div>")
      $("body").append el
      
      # it's self-rendering, not calling render()
      view = new QuestAdd(
        collection: new QuestCollection()
        el: el
      )

    describe "realm", ->
      it "can be chosen", ->
        expect(view.$(".quest-add-realm button")).not.toHaveClass "active"
        view.$("[data-realm-id=europe]").click()
        expect(view.$(".quest-add-realm button")).toHaveClass "active"


    describe "go button", ->
      it "not clickable initially", ->
        expect(view.$(".btn-primary")).toHaveClass "disabled"

      it "not clickable after realm is chosen", ->
        view.$("[data-realm-id=europe]").click()
        expect(view.$(".btn-primary")).toHaveClass "disabled"

      it "not clickable after the first symbol", ->
        view.$("[name=name]").val "A"
        e = $.Event("keyup")
        e.which = 65 # A
        view.$("[name=name]").trigger e
        expect(view.$(".btn-primary")).toHaveClass "disabled"

      it "clickable after realm is chosen and name entered", ->
        view.$("[data-realm-id=europe]").click()
        view.$("[name=name]").val "A"
        e = $.Event("keyup")
        e.which = 65 # A
        view.$("[name=name]").trigger e
        expect(view.$(".btn-primary")).not.toHaveClass "disabled"


    describe "tags", ->
      it "trimmed tag values sent to server", ->
        view.$("[data-realm-id=europe]").click()
        view.$("[name=name]").val "B"
        e = $.Event("keyup")
        e.which = 66
        view.$("[name=name]").trigger e
        view.$("[name=tags]").val "   foo,  bar , baz ,"
        view.$(".btn-primary").click()
        expect($.ajax.mostRecentCall.args[0].data).toContain "[\"bar\",\"baz\",\"foo\"]"




