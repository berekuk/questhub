define ["views/quest/big", "models/quest", "jasmine-jquery"], (QuestBig, QuestModel) ->
    describe "quest-big", ->
        beforeEach ->
            spyOn $, "ajax"
            sinon.spy mixpanel, "track"
        afterEach ->
            mixpanel.track.restore()

        describe "render: ", ->
            describe "non-empty team", ->
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
                view = new QuestBig(model: model)
                view.render()
                it "\"is on a quest\"", ->
                    expect(view.$el.html()).toContain "is on a quest"
                    expect(view.$el.html()).toContain "badger"

                it "not \"suggests a quest\"", ->
                    expect(view.$el.html()).not.toContain "suggests a quest"


            describe "empty team", ->
                model = new QuestModel(
                    ts: 1360197975
                    status: "closed"
                    _id: "5112f9577a8f1d370b000002"
                    team: []
                    name: "Badger Badger"
                    author: "jonti"
                    tags: ["feature"]
                    likes: ["mushroom", "snake"]
                    realm: "chaos"
                )
                view = new QuestBig(model: model)
                view.render()
                it "not \"is on a quest\"", ->
                    expect(view.$el.html()).not.toContain "is on a quest"

                it "\"suggests a quest\"", ->
                    expect(view.$el.html()).toContain "suggests a quest"



        describe "edit: ", ->
            createView = ->
                model = new QuestModel(
                    ts: 1360197975
                    status: "closed"
                    _id: "5112f9577a8f1d370b000002"
                    team: ["jasmine"]
                    name: "Badger Badger"
                    author: "jasmine"
                    tags: ["feature"]
                    likes: ["mushroom", "snake"]
                    realm: "chaos"
                )
                view = new QuestBig(model: model)
                view.render()
                view

            describe "before edit is clicked", ->
                view = createView()
                it "title is visible", ->
                    expect(view.$el.find("h2 .quest-big-editable")).not.toHaveCss display: "none"

                it "'start edit' event not tracked yet", ->
                    expect(mixpanel.track.calledOnce).not.toBe true


            describe "after edit is clicked", ->
                view = undefined
                beforeEach ->
                    view = createView()
                    view.$(".edit").click()

                it "title is hidden", ->
                    expect(view.$el.find("h2 .quest-big-editable")).toHaveCss display: "none"

                it "'start edit' event tracked", ->
                    expect(mixpanel.track.calledOnce).toBe true
                    expect(mixpanel.track.calledWith("start edit", entity: "quest")).toBe true


            describe "if enter is pressed", ->
                view = undefined
                beforeEach ->
                    view = createView()
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
                view = undefined
                beforeEach ->
                    view = createView()
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
                view = undefined
                beforeEach ->
                    view = createView()
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
                view = undefined
                beforeEach ->
                    view = createView()
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
