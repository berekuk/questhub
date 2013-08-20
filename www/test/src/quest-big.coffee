define [
    "views/quest/big", "models/quest", "jasmine-jquery"
], (QuestBig, QuestModel) ->
    describe "quest-big", ->
        model = undefined

        beforeEach ->
            model = new QuestModel(
                ts: 1360197975
                status: "closed"
                _id: "5112f9577a8f1d370b000002"
                team: ["badger"]
                name: "Badger Badger"
                author: "jonti"
                tags: ["feature"]
                likes: ["mushroom", "snake"]
                realm: "chaos"
            )
            spyOn $, "ajax"
            sinon.spy mixpanel, "track"
        afterEach ->
            mixpanel.track.restore()

        describe "render: ", ->
            view = undefined
            describe "non-empty team", ->
                beforeEach ->
                    model.set "status", "open"
                    view = new QuestBig model: model
                    view.render()

                it '"is on a quest"', ->
                    expect(view.$el.html()).toMatch /is\s+on\s+a\s+quest/
                    expect(view.$el.html()).toContain "badger"

                it 'not "suggests a quest"', ->
                    expect(view.$el.html()).not.toMatch /suggests\s+a\s+quest/

            describe "empty team", ->
                beforeEach ->
                    model.set "team", []
                    model.set "status", "open"
                    view = new QuestBig model: model
                    view.render()

                it 'not "is on a quest"', ->
                    expect(view.$el.html()).not.toMatch /is\s+on\s+a\s+quest/

                it '"suggests a quest"', ->
                    expect(view.$el.html()).toMatch /suggests\s+a\s+quest/

            describe "abandoned", ->
                beforeEach ->
                    model.set "status", "abandoned"
                    view = new QuestBig model: model
                    view.render()

                it 'text', ->
                    expect(view.$el.html()).toMatch /was\s+on\s+a\s+quest/

            describe "abandoned by a team", ->
                beforeEach ->
                    model.set "team", ["foo", "bar"]
                    model.set "status", "abandoned"
                    view = new QuestBig model: model
                    view.render()

                it 'text', ->
                    expect(view.$el.html()).toMatch /were\s+on\s+a\s+quest/

            describe "completed", ->
                beforeEach ->
                    model.set "status", "closed"
                    view = new QuestBig model: model
                    view.render()

                it 'text', ->
                    expect(view.$el.html()).toMatch /completed\s+a\s+quest/



        describe "edit: ", ->
            view = undefined
            beforeEach ->
                model.set "team", ["jasmine"]
                model.set "author", "jasmine"
                view = new QuestBig model: model
                view.render()

            describe "before edit is clicked", ->
                it "title is visible", ->
                    expect(view.$el.find("h2 .quest-big-editable")).not.toHaveCss display: "none"

                it "'start edit' event not tracked yet", ->
                    expect(mixpanel.track.calledOnce).not.toBe true


            describe "after edit is clicked", ->
                beforeEach ->
                    view.$(".edit").click()

                it "title is hidden", ->
                    expect(view.$el.find("h2 .quest-big-editable")).toHaveCss display: "none"

                it "'start edit' event tracked", ->
                    expect(mixpanel.track.calledOnce).toBe true
                    expect(mixpanel.track.calledWith("start edit", entity: "quest")).toBe true


            describe "if enter is pressed", ->
                beforeEach ->
                    view.$(".edit").click()
                    spyOn view.model, "save"
                    view.$("[name=name]").val "Mushroom! Mushroom!"
                    e = $.Event("keyup")
                    e.which = 13 # enter
                    view.$("[name=name]").trigger e

                it "title is visible", ->
                    expect(view.$el.find("h2 .quest-big-editable")).not.toHaveCss display: "none"

                it "model is saved", ->
                    expect(view.model.save).toHaveBeenCalledWith
                        name: "Mushroom! Mushroom!"
                        tags: ["feature"]
                        description: ""


            describe "if enter is pressed on invalid data", ->
                beforeEach ->
                    view.$(".edit").click()
                    spyOn view.model, "save"
                    view.$("[name=tags]").val "a,,,,,,,,b"
                    e = $.Event("keyup")
                    e.which = 13 # enter
                    view.$("[name=tags]").trigger e

                it "title is hidden", ->
                    expect(view.$el.find("h2 .quest-big-editable")).toHaveCss display: "none"

                it "model is not saved", ->
                    expect(view.model.save).not.toHaveBeenCalled()


            describe "if escape is pressed", ->
                beforeEach ->
                    view.$(".edit").click()
                    spyOn view.model, "save"
                    view.$("[name=name]").val "Mushroom! Mushroom!"
                    e = $.Event("keyup")
                    e.which = 27 # escape
                    view.$("[name=name]").trigger e

                it "title is visible", ->
                    expect(view.$el.find("h2 .quest-big-editable")).not.toHaveCss display: "none"

                it "model is not saved", ->
                    expect(view.model.save).not.toHaveBeenCalled()

                it "title is not changed", ->
                    expect(view.$el.find("h2 .quest-big-editable").text()).toEqual "Badger Badger"


            describe "if escape is pressed on invalid data", ->
                beforeEach ->
                    view.$(".edit").click()
                    spyOn view.model, "save"
                    view.$("[name=tags]").val "a,,,,,,,,b"
                    e = $.Event("keyup")
                    e.which = 27 # escape
                    view.$("[name=tags]").trigger e

                it "title is visible", ->
                    expect(view.$el.find("h2 .quest-big-editable")).not.toHaveCss display: "none"

                it "model is not saved", ->
                    expect(view.model.save).not.toHaveBeenCalled()

                it "title is not changed", ->
                    expect(view.$el.find("h2 .quest-big-editable").text()).toEqual "Badger Badger"
