define [
    "jquery"
    "spec/fixtures/models"
    "models/current-user"
    "views/user/settings"
], ($, fixtures, currentUser, View) ->
    describe "settings:", ->

        view = undefined
        server = undefined

        beforeEach ->
            $("body").append('<div id="fixture"></div>')
            sinon.spy mixpanel, "track"

            server = sinon.fakeServer.create()
            server.respondWith "GET", "/api/current_user/settings", [200,
                "Content-Type": "application/json"
            , JSON.stringify(fixtures.settings)]

            currentUser.set "settings", fixtures.settings
            view = new View()
            view.setElement $("#fixture") # to make it visible
        afterEach ->
            $("#fixture").remove()
            mixpanel.track.restore()
            server.restore()

        it "view model initializes from current user settings", ->
            expect(view.model.get "notify_likes",).toEqual "1"

        it "checkbox data is based on model", ->
            view.render()
            expect(view.$("[name=notify-likes]")).toBeChecked()
            expect(view.$("[name=notify-comments]")).not.toBeChecked()

        describe "email status", ->
            it "is hidden initially", ->
                view.render()
                expect(view.$(".label-success")).not.toBeVisible()

            it "revealed when settings are fetched from server", ->
                view.render()
                server.respond()
                expect(view.$(".label-success")).toBeVisible()
                expect(view.$(".label-success")).toHaveText "Confirmed"

            it "disappears on typing", ->
                view.render()
                server.respond()

                e = $.Event("keyup")
                e.which = 65 # A
                input = view.$("[name=email]")
                input.val(input.val() + "A")
                input.trigger e

                expect(view.$(".label-success")).not.toBeVisible()
