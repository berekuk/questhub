define [
    "views/register"
    "models/current-user"
], (Register, currentUser) ->
    describe "register:", ->

        # FIXME - currentUser should be registered=0, it's a complete accident these tests are working!

        server = undefined
        beforeEach ->
            sinon.spy mixpanel, "track"
            server = sinon.fakeServer.create()
        afterEach ->
            mixpanel.track.restore()
            server.restore()

        view = undefined
        beforeEach ->
            view = new Register(model: currentUser)

        typeLogin = (text) ->
            view.$("[name=login]").val text
            e = $.Event("keyup")
            e.which = 65 # A - we just want to trigger keyup once
            view.$("[name=login]").trigger e

        typeEmail = (text) ->
            view.$("[name=email]").val text
            e = $.Event("keyup")
            e.which = 65 # A
            view.$("[name=email]").trigger e

        describe "initially", ->
            beforeEach ->
                view.render()

            it "register button is disabled", ->
                expect(view.$el.find ".submit").toHaveClass 'disabled'
            it "cancel button is enabled", ->
                expect(view.$el.find ".cancel").not.toHaveClass 'disabled'

            it "clicking Register does nothing", ->
                view.$(".submit").click()
                server.respond()
                expect(server.requests.length).not.toBeTruthy

        describe "after login is not empty", ->
            beforeEach ->
                view.render()
                typeLogin "foo"

            it "register button is still disabled", ->
                expect(view.$(".submit")).toHaveClass 'disabled'

            it "clicking Register does nothing", ->
                view.$(".submit").click()
                server.respond()
                expect(server.requests.length).not.toBeTruthy

        describe "after login AND email are not empty", ->
            beforeEach ->
                view.render()
                typeLogin "foo"
                typeEmail "foo@example.com"

            it "register button is enabled", ->
                expect(view.$(".submit")).not.toHaveClass 'disabled'

            it "clicking Register sends a request", ->
                view.$(".submit").click()
                server.respond()
                expect(server.requests.length).toBeTruthy
                expect(server.requests[0].requestBody).toMatch 'login=foo'
                expect(server.requests[0].requestBody).toMatch 'email%22%3A%22foo%40example.com'
