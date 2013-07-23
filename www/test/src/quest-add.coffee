define ["jquery", "views/quest/add", "models/quest-collection", "jasmine-jquery"], ($, QuestAdd, QuestCollection) ->
    describe "quest-add:", ->
        view = undefined
        beforeEach ->
            spyOn $, "ajax"
            view.remove() if view

            # it's self-rendering, not calling render()
            view = new QuestAdd(
                collection: new QuestCollection()
            )

        describe "realm:", ->
            it "can be chosen via list", ->
                expect(view.$(".quest-add-realm-list li")).not.toHaveClass "active"
                view.$("[data-realm=europe] a").click()
                expect(view.$(".quest-add-realm-list li")).toHaveClass "active"

            it "list changes select", ->
                expect(view.$(".quest-add-realm-select [value=europe]")).not.toBeSelected()
                view.$("[data-realm=europe] a").click()
                expect(view.$(".quest-add-realm-select [value=europe]")).toBeSelected()
            # TODO - test that select changes list as well

            it "choosing reveals image", ->
                expect(view.$(".realm-sv")).not.toContain("img")
                view.$("[data-realm=europe] a").click()
                expect(view.$(".realm-sv")).toContain("img")

        describe "go button", ->
            it "not clickable initially", ->
                expect(view.$("button._go")).toHaveClass "disabled"

            it "not clickable after realm is chosen", ->
                view.$("[data-realm=europe] a").click()
                expect(view.$("button._go")).toHaveClass "disabled"

            it "not clickable after the first symbol", ->
                view.$("[name=name]").val "A"
                e = $.Event("keyup")
                e.which = 65 # A
                view.$("[name=name]").trigger e
                expect(view.$("button._go")).toHaveClass "disabled"

            it "clickable after realm is chosen and name entered", ->
                view.$("[data-realm=europe] a").click()
                view.$("[name=name]").val "A"
                e = $.Event("keyup")
                e.which = 65 # A
                view.$("[name=name]").trigger e
                expect(view.$("button._go")).not.toHaveClass "disabled"


        describe "tags", ->
            it "trimmed tag values sent to server", ->
                view.$("[data-realm=europe] a").click()
                view.$("[name=name]").val "B"
                e = $.Event("keyup")
                e.which = 66
                view.$("[name=name]").trigger e
                view.$("[name=tags]").val "   foo,  bar , baz ,"
                view.$("button._go").click()
                expect($.ajax.mostRecentCall.args[0].data).toContain "[\"bar\",\"baz\",\"foo\"]"
