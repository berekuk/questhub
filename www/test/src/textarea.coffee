define [
    "jquery", "views/helper/textarea"
], ($, Textarea) ->
    describe "textarea:", ->
        it "is not active initially", ->
            expect(Textarea.active()).not.toBe true

        it "is not active after reveal", ->
            view = new Textarea(realm: "europe", placeholder: "Blah")
            view.render()
            view.reveal("")
            expect(Textarea.active()).not.toBe true

        it "is active if has revealed content", ->
            view = new Textarea(realm: "europe", placeholder: "Blah")
            view.render()
            view.reveal("something")
            expect(Textarea.active()).toBe true

        it "is active if content is typed in", ->
            $("body").append('<div id="fixture"></div>')

            view = new Textarea(realm: "europe", placeholder: "Blah")
            view.setElement $("#fixture") # otherwise view disables itself because it's not :visible
            view.render()
            view.reveal("")

            e = $.Event("keyup")
            e.which = 65 # A - we just want to trigger keyup once
            view.$("textarea").val("A")
            view.$("textarea").trigger e

            expect(Textarea.active()).toBe true
            $("#fixture").remove()
