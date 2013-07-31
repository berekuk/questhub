define [
    "jquery", "views/helper/textarea"
], ($, Textarea) ->
    describe "textarea:", ->
        beforeEach -> $("body").append('<div id="fixture"></div>')
        afterEach -> $("#fixture").remove()

        create = (text) ->
            text = "" unless text?
            view = new Textarea(realm: "europe", placeholder: "Blah")
            view.setElement $("#fixture") # otherwise view disables itself because it's not :visible
            view.render()
            view.reveal(text)
            view

        it "is not active initially", ->
            expect(Textarea.active()).not.toBe true

        it "is not active after reveal", ->
            view = create()
            expect(Textarea.active()).not.toBe true

        it "is active if has revealed content", ->
            view = create("something")
            expect(Textarea.active()).toBe true

        it "is active if content is typed in", ->
            view = create()

            e = $.Event("keyup")
            e.which = 65 # A - we just want to trigger keyup once
            view.$("textarea").val("A")
            view.$("textarea").trigger e

            expect(Textarea.active()).toBe true

        describe "preview", ->
            it "is not updated on reveal by default", ->
                view = create("blah")
                expect(view.$(".helper-textarea-preview")).not.toBeVisible()
                expect(view.$(".helper-textarea-preview ._content").html()).toEqual ""

            it "is updated on reveal if preview is on", ->
                view = create("blah")
                view.$(".helper-textarea-show-preview").click()
                expect(view.$(".helper-textarea-preview")).toBeVisible()
                expect(view.$(".helper-textarea-preview ._content").html()).toEqual "<p>blah</p>"

            it "is cleared on clear()", ->
                view = create("blah")
                view.$(".helper-textarea-show-preview").click()
                view.clear()
                expect(view.$(".helper-textarea-preview")).not.toBeVisible()

                e = $.Event("keyup")
                e.which = 65 # A - we just want to trigger keyup once
                view.$("textarea").val("A")
                view.$("textarea").trigger e
                expect(view.$(".helper-textarea-preview")).toBeVisible()
                expect(view.$(".helper-textarea-preview ._content").html()).toEqual "<p>A</p>"

            it "looks like markdown", ->
                view = create("*blah*")
                view.$(".helper-textarea-show-preview").click()
                expect(view.$(".helper-textarea-preview")).toBeVisible()
                expect(view.$(".helper-textarea-preview ._content").html()).toEqual "<p><em>blah</em></p>"

