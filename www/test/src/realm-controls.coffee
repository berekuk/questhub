define [
    "views/realm/controls"
    "models/realm", "models/current-user"
    "jasmine-jquery"
], (RealmControls, RealmModel, currentUser) ->
    describe "realm controls:", ->
        server = undefined
        beforeEach ->
            sinon.spy mixpanel, "track"
            server = sinon.fakeServer.create()
        afterEach ->
            mixpanel.track.restore()
            server.restore()

        model = undefined
        view = undefined
        beforeEach ->
            model = new RealmModel
                id: "europe"
                name: "Europe"
                description: "europe-europe"
                keepers: []
                pic: "europe.png"

            view = new RealmControls model: model
            view.render()

        describe "follow button", ->
            it "is set to 'follow' initially", ->
                expect(view.$("button").text()).toEqual "Follow"

        describe "clicking unfollow", ->
            beforeEach ->
                server.respondWith "GET", "/api/current_user", [
                    200
                    "Content-Type": "application/json"
                    JSON.stringify
                        registered: 1,
                        login: 'jasmine',
                        _id: '12345678901234567890abcd',
                        settings: {},
                        notifications: [],
                        pic: "/current-user.png"
                        fr: ['europe']
                ]

            it "changes button text to 'unfollow'", ->
                view.$("button").click()
                expect(view.$("button").text()).toEqual "Follow" # not yet - waiting for server response
                server.respond()
                expect(view.$("button").text()).toEqual "Unfollow"
                expect(server.requests.length).toEqual 2 # follow, and then refetch self
